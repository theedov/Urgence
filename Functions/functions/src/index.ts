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

//add the path to receive request and set json as bodyParser to process the body
main.use('/v1', app);
main.use(bodyParser.json());
main.use(bodyParser.urlencoded({extended: false}));

//define google cloud function name
export const api = functions.https.onRequest(main);

// Receive camera_id & image from a camera and send push notification to user's device
app.post('/camera', async (req, res) => {

    //Authorization
    const tokenId = req.get('Authorization')?.split('Bearer ')[1];
    if (tokenId != functions.config().api.key) {
        res.status(403).json({
            error: true,
            errorMessage: 'Unauthorized'
        });
    }

    //Variables checking
    const camera_id = req.body['camera_id'];
    const image_binary = req.body['image_binary'];
    // const errors: any[] = [];

    if (!camera_id || !image_binary) {
        res.status(400).json({
            error: true,
            errorMessage: 'Data should contain camera_id, image_binary!'
        });
    }

    let db = admin.firestore();
    //Search in devices collection for userId
    db.collection("devices").where("deviceId", "==", camera_id)
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
                            uploadImageToStorageAndPushNotify(image_binary, camera_id, user.id, user.key);
                            res.status(200).json({
                                error: false,
                                message: "Push notification has been sent"
                            });

                        } else {
                            console.log("No user document found");
                            res.status(400).json({
                                error: true,
                                errorMessage: "No user found"
                            });
                        }
                    }).catch(function (error) {
                        console.log("Error getting user document:", error);
                        res.status(500).json({
                            error: true,
                            errorMessage: "Error getting user document: " + error
                        });
                    });
                });
            } else {
                res.status(400).json({
                    error: true,
                    message: "No devices found"
                });
            }
        })
        .catch(function (error) {
            console.log("Error getting devices collection:", error);
            res.status(500).json({
                error: true,
                errorMessage: "Error getting devices collection" + error
            });
        });

});

function uploadImageToStorageAndPushNotify(imageBinary: string, deviceId: string, userId: string, groupKey: string) {
    const bucket = admin.storage().bucket();
    const imageBuffer = Buffer.from(imageBinary, 'base64');
    const imageByteArray = new Uint8Array(imageBuffer);
    const file = bucket.file(`${userId}/devices/${deviceId}/notifications/${Date.now().toString()}.jpg`);
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

//
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
