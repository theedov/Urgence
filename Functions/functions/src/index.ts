//import libraries
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as express from 'express';
import * as bodyParser from "body-parser";

//initialize firebase inorder to access its services
admin.initializeApp(functions.config().firebase);

//initialize express server
const app = express();
const main = express();
var error = false;
var errorMessage = "";

//add the path to receive request and set json as bodyParser to process the body
main.use('/v1', app);
main.use(bodyParser.json());
main.use(bodyParser.urlencoded({extended: false}));

//define google cloud function name
export const api = functions.https.onRequest(main);

// Receive device_id & image from a camera and send push notification to user's device
app.post('/camera', async (req, res) => {

    //Authorization
    const tokenId = req.get('Authorization')?.split('Bearer ')[1];
    if (tokenId != functions.config().api.key) {
        res.status(403).json({
            error: true,
            errorMessage: '/camera: Unauthorized'
        });
    }

    //Variables checking
    const device_id = req.body['device_id'];
    const image_binary = req.body['image_binary'];

    if (!device_id || !image_binary) {
        res.status(400).json({
            error: true,
            errorMessage: '/camera: Data should contain device_id, image_binary!'
        });
    }

    let db = admin.firestore();
    //Search in devices collection for userId
    db.collection("devices").where("deviceId", "==", device_id)
        .get()
        .then(function (querySnapshot) {
            if (!querySnapshot.empty) {
                querySnapshot.forEach(function (doc) {
                    let device = doc.data();
                    let userRef = db.collection("users").doc(device.userId);

                    userRef.get().then(function (doc) {
                        if (doc.exists) {
                            let user = doc.data();

                            //send push notification to users who have a device with the {deviceId} in users db
                            // @ts-ignore
                            // sendNotification(user.key, image_binary);
                            uploadImageToStorageAndPushNotify(image_binary, device_id, user.id, user.key);
                        }
                    }).catch(function (error) {
                        console.log("/camera: Error getting user document:", error);
                        error = true;
                        errorMessage = error
                    });
                });
            } else {
                console.log("/camera: No device found");
                error = true;
                errorMessage = "No device found";
            }
        })
        .catch(function (error) {
            console.log("/camera: Error getting devices collection:", error);
            error = true;
            errorMessage = error;
        });

    if (error) {
        res.status(500).json({
            error: true,
            errorMessage: errorMessage
        });
    } else {
        res.status(200).json({
            error: false,
            errorMessage: "ok"
        });
    }

});

// Receive device_id & image from a camera and send push notification to user's device
app.post('/version', async (req, res) => {

    //Authorization
    const tokenId = req.get('Authorization')?.split('Bearer ')[1];
    if (tokenId != functions.config().api.key) {
        res.status(403).json({
            error: true,
            errorMessage: 'Unauthorized'
        });
    }

    //Variables checking
    const device_id = req.body['device_id'];

    if (!device_id) {
        res.status(400).json({
            error: true,
            errorMessage: 'Data should contain device_id!'
        });
    }

    let db = admin.firestore();

    //find latest added version id DB
    db.collection("versions").orderBy("releaseDate", "desc").limit(1)
        .get()
        .then(snap => {
            if (!snap.empty) {
                let latestVersion = snap.docs[0].data().versionId;
                let storage = admin.storage();

                //find device by its id in DB
                db.collection("devices").where("deviceId", "==", device_id).limit(1)
                    .get()
                    .then(snap => {
                        if (!snap.empty) {
                            let device = snap.docs[0].data();
                            //check if device version is out of date and if updates are enabled
                            if (device.versionId != latestVersion && device.update == true) {
                                //find version file in storage, and get URL to download
                                let file = storage.bucket().file("versions/" + latestVersion + ".zip");
                                file.getSignedUrl({
                                    action: 'read',
                                    expires: '01-01-2125'
                                }).then(results => {
                                    console.info("version: Version file found");
                                    res.status(200).json({
                                        version_id: latestVersion,
                                        file_url: results[0]
                                    });
                                }).catch(error => {
                                    console.error("/version: " + error);
                                });
                            } else {
                                console.info("/version: Device is up to date or updates are disabled");
                                res.status(200).json({
                                    message: "Device is up to date or updates are disabled"
                                });
                            }
                        }
                    });
            }
        })
        .catch(error => {
            console.error("/version: " + error);
        });
});

app.post('/updated', async (req, res) => {

    //Authorization
    const tokenId = req.get('Authorization')?.split('Bearer ')[1];
    if (tokenId != functions.config().api.key) {
        res.status(403).json({
            error: true,
            errorMessage: 'Unauthorized'
        });
    }

    //Variables
    const device_id = req.body['device_id'];
    const version_id = req.body['version_id'];

    //Variables checking
    if (!device_id || !version_id) {
        res.status(400).json({
            error: true,
            errorMessage: 'Data should contain device_id & version_id!'
        });
    }

    let db = admin.firestore();
    //find devices with deviceId in DB
    db.collection("devices").where("deviceId", "==", device_id)
        .get()
        .then(snap => {
            if (!snap.empty) {
                snap.forEach(doc => {
                    //check if device updates are enabled
                    if (doc.data().update == true) {
                        //update device document(set new versionId)
                        db.collection("devices").doc(doc.id).update({versionId: version_id})
                            .then(_ => {
                                console.info("/updated: Device versionId has been updated.");
                                res.status(200).json({
                                    error: false,
                                    errorMessage: "ok"
                                });
                            })
                            .catch(error => {
                                console.error("/updated: " + error);
                                res.status(500).json({
                                    error: true,
                                    errorMessage: error
                                });
                            });
                    } else {
                        console.error("/updated: Updates are disabled");
                        res.status(500).json({
                            error: true,
                            errorMessage: "Updates are disabled"
                        });
                    }
                });
            }
        })
        .catch(error => {
            console.error("/updated: " + error);
            res.status(500).json({
                error: true,
                errorMessage: error
            });
        });
});

function uploadImageToStorageAndPushNotify(imageBinary: string, deviceId: string, userId: string, groupKey: string) {
    const bucket = admin.storage().bucket();
    const imageBuffer = Buffer.from(imageBinary, 'base64');
    const imageByteArray = new Uint8Array(imageBuffer);
    const file = bucket.file(`users/${userId}/devices/${deviceId}/notifications/${Date.now().toString()}.jpg`);
    const options = {resumable: false, metadata: {contentType: "image/jpg"}};

    //options may not be necessary
    return file.save(imageByteArray, options)
        .then(stuff => {
            return file.getSignedUrl({
                action: 'read',
                expires: '03-09-2500'
            })
        })
        .then(urls => {
            const url = urls[0];
            sendNotification(groupKey, url);
        })
        .catch(err => {
            console.log(`Unable to upload image ${err}`, err);
        })
}

function sendNotification(groupKey: string, imageUrl: string) {
    const payload = {
        notification: {
            title: '',
            subtitle: '',
            body: 'A camera noticed suspicious behavior',
            badge: '1',
            sound: 'default',
        },
        data: {
            url: imageUrl,
            image: imageUrl,
            dl: 'au.com.urgence://notification'
        }
    };

    const options = {
        priority: "high",
        mutableContent: true,
        contentAvailable: true
    };


    admin.messaging().sendToDeviceGroup(
        groupKey,
        payload,
        options
    ).then(r => {
        console.log("Notification has been sent");
    }).catch(e => {
        console.log("Error sending push notification", e);
    });
}
