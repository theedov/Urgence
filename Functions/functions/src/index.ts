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
const db = admin.firestore();
const storage = admin.storage().bucket();
const {v4: uuidv4} = require('uuid');

//db
const usersDb = db.collection("users");
const devicesDb = db.collection("devices");
const notificationsDb = db.collection("notifications");
const versionsDb = db.collection("versions");

let error = false;
let errorMessage = "";

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

    //Config for upload to storage
    const imageBuffer = Buffer.from(image_binary, 'base64');
    const imageByteArray = new Uint8Array(imageBuffer);
    const path = `notifications/${Date.now().toString()}.jpg`;
    const file = storage.file(path);
    const options = {resumable: false, metadata: {contentType: "image/jpg"}};

    //upload to storage and get URL
    let url = await file.save(imageByteArray, options)
        .then(_ => {
            return file.getSignedUrl({
                action: 'read',
                expires: '03-09-2500'
            });
        })
        .then(urls => {
            return urls[0];
        })
        .catch(err => {
            console.log(`Unable to upload image`, err);
            return null;
        });

    // Find all registered devices with device_id,
    // then add notification to the database for each user who has device with device_id added in their app,
    // and then send a push notification to all these users
    if (url != null) {
        devicesDb.where("deviceId", "==", device_id)
            .get()
            .then(snap => {
                if (!snap.empty) {
                    snap.forEach(doc => {
                        const device = doc.data();
                        const uniqueId = uuidv4();

                        //find user by userId
                        usersDb.doc(device.userId)
                            .get()
                            .then(doc => {
                                if (doc.exists) {
                                    const user = doc.data();

                                    //add notification to DB
                                    notificationsDb.add({
                                        id: uniqueId,
                                        userId: user!.id,
                                        deviceId: device_id,
                                        title: device.name,
                                        imageUrl: url,
                                        imagePath: path,
                                        viewed: false,
                                        accepted: false,
                                        declined: false,
                                        createdAt: admin.firestore.FieldValue.serverTimestamp()
                                    }).then(_ => {
                                        //send push notification
                                        sendNotification(user!.key, url ?? "");
                                        console.log("notification added to the database");
                                    }).catch(error => {
                                        console.error(`Unable to add notification to db`, error);
                                        error = true;
                                        errorMessage = error;
                                    })
                                }
                            }).catch(function (error) {
                            console.error("/camera: Error getting user document:", error);
                            error = true;
                            errorMessage = error;
                        });
                    });
                }
            })
            .catch(function (error) {
                console.error("/camera: Error getting devices collection:", error);
                error = true;
                errorMessage = error;
            });
    }

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

// This function returns a downloadable URL to new version of ML file,
// but only if device has enabled automatic updated and there is a higher version available.
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

    //find latest added version id DB
    versionsDb.orderBy("releaseDate", "desc").limit(1)
        .get()
        .then(snap => {
            if (!snap.empty) {
                let latestVersion = snap.docs[0].data().versionId;
                let storage = admin.storage();

                //find device by its id in DB
                devicesDb.where("deviceId", "==", device_id).limit(1)
                    .get()
                    .then(snap => {
                        if (!snap.empty) {
                            let device = snap.docs[0].data();
                            //check if device version is out of date and if updates are enabled
                            if ((device.versionId != latestVersion) && (device.versionId < latestVersion) && (device.update == true)) {
                                //find version file in storage, and get URL to download
                                let file = storage.bucket().file("versions/" + latestVersion + ".zip");
                                file.getSignedUrl({
                                    action: 'read',
                                    expires: '01-01-2125'
                                }).then(results => {
                                    console.info("version: Version file found");
                                    res.status(200).json({
                                        error: false,
                                        require_update: true,
                                        new_version: latestVersion,
                                        file_url: results[0]
                                    });
                                }).catch(error => {
                                    console.error("/version: " + error);
                                    res.status(500).json({
                                        error: true,
                                        require_update: false,
                                        message: error
                                    });
                                });
                            } else {
                                console.info("/version: Device is up to date or updates are disabled");
                                res.status(200).json({
                                    error: false,
                                    require_update: false,
                                    message: "Device is up to date or updates are disabled"
                                });
                            }
                        } else {
                            console.error("/version: Device not found");
                            res.status(500).json({
                                error: true,
                                message: "Device not found"
                            });
                        }
                    });
            }
        })
        .catch(error => {
            console.error("/version: " + error);
            res.status(500).json({
                error: true,
                message: error
            });
        });
});

// This function updates versionId of each device where deviceId = posted device_id
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

    //find devices with deviceId in DB
    devicesDb.where("deviceId", "==", device_id)
        .get()
        .then(snap => {
            if (!snap.empty) {
                snap.forEach(doc => {
                    //check if device updates are enabled
                    if (doc.data().update == true) {
                        //update device document(set new versionId)
                        devicesDb.doc(doc.id).update({versionId: version_id})
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
            } else {
                console.error("/version: Device not found");
                res.status(500).json({
                    error: true,
                    message: "Device not found"
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

// This returns list of urls to images that users "accepted" in the NotificationVC screen
// Mainly used to retrain the ML model
app.post('/acceptedFilesList', async (req, res) => {

    //Authorization
    const tokenId = req.get('Authorization')?.split('Bearer ')[1];
    if (tokenId != functions.config().api.key) {
        res.status(403).json({
            error: true,
            errorMessage: 'Unauthorized'
        });
    }
    const urls: any[] = [];
    const [files] = await storage.getFiles({directory: 'notifications/accepted'});

    for (const file of files) {
        let filePath = file.name;
        let url = await storage.file(filePath).getSignedUrl({
            action: 'read',
            expires: '03-09-2500'
        });
        console.log(url);
        urls.push(url);
    }

    res.status(200).json({urls});
});

// This updates a notification viewed state, when user opens a notification for the first time
exports.onNotificationOpen = functions.https.onCall(async (data, context) => {
    //Variables checking
    const notification_id = data.notification_id;
    if (!notification_id) {
        return false;
    }

    //Set notification as viewed

    return await notificationsDb.where("id", "==", notification_id).get()
        .then(snap => {
            if (!snap.empty) {
                snap.forEach(doc => {
                    notificationsDb.doc(doc.id).update({
                        viewed: true
                    }).catch(error => {
                        console.error("Could not update notification", error);
                    });
                });
                return true
            } else {
                return false
            }
        });
});

// When user accepts a notification in the NotificationVC screen, it copies a notification image to "accepted" folder in storage.
// Mainly used to retrain ML model by calling /acceptedFilesList request, which returns array of "accepted" images.
exports.onAcceptPrediction = functions.https.onCall(async (data, context) => {
    //Variables checking
    const path = data.path;
    const notification_id = data.notification_id;
    if (!path || !notification_id) {
        return false;
    }

    //Copy file
    const file = storage.file(path);
    return await file.copy(`notifications/accepted/${Date.now().toString()}.jpg`)
        .then(async _ => {
            console.log("onAcceptPrediction: Accepted prediction file successfully copied");
            //Set as accepted in DB
            return await notificationsDb.where("id", "==", notification_id).get()
                .then(snap => {
                    if (!snap.empty) {
                        snap.forEach(doc => {
                            notificationsDb.doc(doc.id).update({
                                accepted: true
                            }).catch(error => {
                                console.error("onDeclinePrediction: Could not update notification", error);
                            });
                        });
                        return true;
                    } else {
                        return false;
                    }
                });


        })
        .catch(error => {
            console.error("onAcceptPrediction: Accepted prediction file could not be copied: ", error);
            return false;
        });

});

// When user declines a notification in the NotificationVC screen, it updated the "decline" state in DB
exports.onDeclinePrediction = functions.https.onCall(async (data, context) => {
    //Variables checking
    const notification_id = data.notification_id;
    if (!notification_id) {
        return false;
    }

    return await notificationsDb.where("id", "==", notification_id).get()
        .then(snap => {
            if (!snap.empty) {
                snap.forEach(doc => {
                    notificationsDb.doc(doc.id).update({
                        declined: true
                    }).catch(error => {
                        console.error("onDeclinePrediction: Could not update notification", error);
                        return false
                    });
                });
            }
            return true;
        });
});


// Send a push notification
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
        console.error("Error sending push notification", e);
    });
}
