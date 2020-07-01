const functions = require('firebase-functions');
const admin = require("firebase-admin");
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.onCreateActivityFeedItem = functions.firestore
    .document("/feedNotification/{userId}/feedItems/{activityFeedItem}")
    .onCreate(async (snapshot, context) => {
        console.log("Activity Feed Item Created", snapshot.data());

        // get the user connected to the feed
        const userId = context.params.userId;
        console.log("userId " + userId);

        const userRef = admin.firestore().doc(`user/${userId}`);
        const doc = await userRef.get();

        //Once we have user, check if they have a notification token;
        //send notification, if they have a token
        const androidNotificationToken = doc.data().androidNotificationToken;
        const createdActivityFeedItem = snapshot.data();
        if (androidNotificationToken) {
            sendNotification(androidNotificationToken, createdActivityFeedItem);
        } else {
            console.log("No token for user, cannot send notification");
        }

        function sendNotification(androidNotificationToken, activityFeedItem) {
            let body;
            let type;

            //switch body value based off notification type
            switch (activityFeedItem.type) {

                case "follow":
                    body = `${activityFeedItem.username} started following you`;
                    type = "follow";
                    break;
                case "likeGarage":
                    body = `${activityFeedItem.username} liked your garage`;
                    type = "likeGarage";
                    break;
                case "commentGarage":
                    body = `${activityFeedItem.username} commented on your garage`;
                    type = "commentGarage";
                    break;

                default:
                    break;
            }

            //create message for push notification
            const message = {
                notification: {
                    body,
                },

                token: androidNotificationToken,
                data: { recipient: userId },
            };

            //Send message with admin.messaging
            admin
                .messaging()
                .send(message)
                .then((response) => {
                    // Response is a message ID String
                    console.log("sent message", response);
                })
                .catch((error) => {
                    console.log(error);
                });
        }
    });
