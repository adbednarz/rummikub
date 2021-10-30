import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {Game} from "./model/game";

admin.initializeApp(functions.config().firebase);

export const searchGame = functions.https.onCall((data, context) => {
  const playerID: string = context.auth?.uid ?? "";
  const size: number = data.playersNumber;
  const firestore: FirebaseFirestore.Firestore = admin.firestore();
  let gameID: string;

  if (playerID === "") {
    throw new functions.https.HttpsError("failed-precondition",
        "The function must be called while authenticated.");
  }
  return firestore.runTransaction((
    (transaction: FirebaseFirestore.Transaction) => {
      return Games.findGame(firestore, transaction, size)
          .then((gameResult: FirebaseFirestore.QuerySnapshot) => {
            if (gameResult.size == 1) {
              const gameSnapshot: FirebaseFirestore.DocumentSnapshot =
                gameResult.docs[0];
              const game: Game = <Game> gameSnapshot.data();
              const players: string[] = [...game.players, playerID];
              const isFull: boolean = players.length == game.size;
              const newGameData: Game = {isFull, size: game.size, players};
              transaction.update(gameSnapshot.ref, newGameData);
              gameID = gameSnapshot.id;
            } else {
              const gameRef: FirebaseFirestore.DocumentReference =
                firestore.collection("games").doc();
              const players: string[] = [playerID];
              transaction.set(gameRef, {isFull: false, size, players});
              gameID = gameRef.id;
            }
            const userRef: FirebaseFirestore.DocumentReference =
                firestore.collection("users").doc(playerID);
            transaction.update(userRef, {"active": false});
          });
    })).then(() => {
    return {"gameID": gameID};
  });
});

class Games {
  static findGame(firestore: FirebaseFirestore.Firestore,
      transaction: FirebaseFirestore.Transaction,
      size: number): Promise<FirebaseFirestore.QuerySnapshot> {
    return transaction.get(firestore.collection("games")
        .where("isFull", "==", false)
        .where("size", "==", size)
        .limit(1));
  }
}
