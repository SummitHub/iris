import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();
const env = functions.config();

import * as algoliasearch from 'algoliasearch';

const client = algoliasearch(env.algolia.appid, env.algolia.apikey);
const index = client.initIndex('test_firestore');

exports.newMessageNotification = functions.firestore
    .document('/chatRooms/{chatId}/messages/{messageId}')
    .onCreate(async snap => {
        const data = snap.data()
        const reciever = await admin.firestore().collection('users').doc(data['recieverID']).get()
        const recieverData = reciever.data();
        const sender = await admin.firestore().collection('users').doc(data['senderID']).get()
        const senderData = sender.data();

        //get the message
        const message = String(data['content']);
        
        //get the message id. We'll be sending this in the payload

        const token = String(recieverData['messagingToken']);
        
        //we have everything we need
        //Build the message payload and send the message
        console.log("Construction the notification message.");
        
        const payload = {
            notification: {
                title: senderData['name'],
                body: message,
                sound: "light.m4r"
            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                status: "done",
                senderID: data['senderID'],
                senderName: senderData['name'],
                senderImage: senderData['picture'],
                senderPosition: senderData['position'],
                recieverID: data['recieverID'],
                type: "chat" 
            }
        };
        return admin.messaging().sendToDevice(token, payload)
            .then(function(response) {
                console.log("Successfully sent message:", response);
            })
            .catch(function(error) {
                console.log("Error sending message:", error);
            });
        
    });

    exports.newMeetingNotification = functions.firestore
        .document('/meetings/{meetingId}')
        .onCreate(async snap => {
            const data = snap.data()
            const host = await admin.firestore().collection('users').doc(data['hostId']).get();
            const hostData = host.data();
            const guests = await admin.firestore().collection('meetings').doc(snap.id).collection('guests').listDocuments();
            let guestTokens = [];

            console.log(guests);
            async function getGuestsTokens() {
                for (const guest of guests) {
                    console.log(guest.id);
                    let temp = await admin.firestore().collection('users').doc(guest.id).get();
                    guestTokens = temp.data()['messagingToken'];
                }
                console.log(guestTokens);
            }
            const formattedDateString = data['startDate']+'T'+ data['startTime'] +'Z';
            const meetingDateTime = new Date(formattedDateString);
            //we have everything we need
            //Build the message payload and send the message
            console.log(meetingDateTime);
            console.log("Construction the notification message.");
            const payload = {
                'notification': {
                    title: 'Nova reunião com ' + hostData['name'],
                    body: 'Local: ' + data['location'] + ', ' + 'Horário: dia ' + String(meetingDateTime.getDate()) + ' às ' + String(meetingDateTime.getUTCHours()) +':'+ String(meetingDateTime.getUTCMinutes()),
                    sound: 'notbad.m4r' 
                },
                'data': {
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    status: 'done',
                    senderID: data['hostId'],
                    type: 'meeting', 
                }
            };
            
            getGuestsTokens()
                .then(
                    () => {
                        return admin.messaging().sendToDevice(guestTokens, payload)
                        .then(function(response) {
                            console.log("Successfully sent message:", response);
                        })
                        .catch(function(error) {
                            console.log("Error sending message:", error);
                        });
                    }
                ).catch(() => {
                    'wow'
                });

                
            
        });


    exports.updateUserIndex = functions.firestore
        .document('users/{userId}')
        .onUpdate((change, context) => {
          // Retrieve the current and previous value
          const data = change.after.data();
          const previousData = change.before.data();
          const userID = change.before.id;
          // We'll only update if the name has changed.
          // This is crucial to prevent infinite loops.
          if (data.about !== previousData.about || data.name !== previousData.name || data.company !== previousData.company || data.position !== previousData.position || data.picture !== previousData.picture) {
            return index.partialUpdateObject({
                userID,
                objectID: userID,
                ...data
            });
          } else {
            return null;
          } 

        });
    
    

exports.indexItem = functions.firestore
    .document('/users/{itemId}')
    .onCreate((snap, context) => {
        const userID = snap.id;
        const data = snap.data();

        return index.addObject({
            userID,
            objectID: userID,
            ...data
        });
    });

exports.unindexItem = functions.firestore
    .document('/users/{itemId}')
    .onDelete((snap, context) => {
        const userID = snap.id;

        return index.deleteObject(userID);
    });

