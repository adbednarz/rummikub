import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {GameUtils} from "./game-utils";

admin.initializeApp();
export const firestore: FirebaseFirestore.Firestore = admin.firestore();

export const searchGame = functions.https.onCall((data, context) => {
  const playerID: string = context.auth?.uid ?? "";
  const size: number = data.playersNumber;
  let gameID: string;

  if (playerID === "") {
    throw new functions.https.HttpsError("failed-precondition",
        "The function must be called while authenticated.");
  }

  return firestore.runTransaction((
    (transaction: FirebaseFirestore.Transaction) => {
      return GameUtils.findGame(transaction, size)
          .then((gameResult: FirebaseFirestore.QuerySnapshot) => {
            if (gameResult.size == 1) {
              gameID = GameUtils.addToGame(transaction, playerID, gameResult);
            } else {
              gameID = GameUtils.createGame(transaction, playerID, size);
            }
            functions.logger.log(playerID);
            const userRef: FirebaseFirestore.DocumentReference =
                firestore.collection("users").doc(playerID);
            transaction.update(userRef, {"active": false});
          });
    })).then(() => {
    return {"gameID": gameID};
  });
});

export const waitGameReadyToStart = functions.firestore
    .document("games/{gameId}/")
    .onUpdate((snapshot) => {
      GameUtils.startGame(snapshot.after);
    });
