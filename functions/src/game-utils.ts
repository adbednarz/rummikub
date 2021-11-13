// import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {firestore} from "./index";
import * as functions from "firebase-functions";

export class GameUtils {
  static checkAuthentication(playerId: string): void {
    if (playerId === "") {
      throw new functions.https.HttpsError("failed-precondition",
          "The function must be called while authenticated.");
    }
  }

  static createGame(transaction: FirebaseFirestore.Transaction, playerId: string, size: number): string {
    const gameRef: FirebaseFirestore.DocumentReference = firestore.collection("games").doc();

    transaction.set(gameRef, {available: size - 1, size: size});

    transaction.set(
        gameRef.collection("playersQueue").doc(playerId),
        {currentTurn: false, initialMeld: false}
    );

    for (const color of ["black", "red", "orange", "blue"]) {
      for (let i = 1; i < 14; i++) {
        for (let j = 0; j < 2; j++) {
          transaction.set(
              gameRef.collection("pool").doc(),
              {[color]: i});
        }
      }
      if (color === "black" || color === "red") {
        transaction.set(
            gameRef.collection("pool").doc(),
            {color: 0}); // 0 === joker
      }
    }

    return gameRef.id;
  }

  static addToGame(transaction: FirebaseFirestore.Transaction, playerId: string,
      gameDoc: FirebaseFirestore.QueryDocumentSnapshot): [string, boolean] {
    transaction.set(
        gameDoc.ref.collection("playersQueue").doc(playerId),
        {currentTurn: false, initialMeld: false}
    );
    const availablePlaces: number = gameDoc.get("available") - 1;
    transaction.update(gameDoc.ref, {available: availablePlaces});
    return [gameDoc.id, availablePlaces == 0];
  }

  static findGame(size: number): FirebaseFirestore.Query {
    return firestore.collection("games")
        .where("available", ">", 0)
        .where("size", "==", size)
        .limit(1);
  }

  static startGame(gameId: string): void {
    const playersId: string[] = [];
    firestore.collection("games/" + gameId + "/playersQueue").get()
        .then((playersDoc) => {
          playersDoc.forEach((doc) => playersId.push(doc.id));
          return firestore.collection("games/" + gameId + "/pool").limit(14 * playersId.length).get();
        })
        .then((tilesDoc) => {
          let counter = 0;
          for (const player of playersId) {
            for (let i = 1; i < 15; i++) {
              const tileDocument = tilesDoc.docs[counter];
              const tileColor = Object.keys(tileDocument.data())[0];
              const tileNumber = Object.values(tileDocument.data())[0];
              firestore.collection("games/" + gameId + "/playersTiles")
                  .doc(player).collection("tiles").doc().set({[tileColor]: tileNumber});
              tileDocument.ref.delete();
              counter++;
            }
          }
          firestore.collection("games").doc(gameId).update({timer: admin.firestore.FieldValue.serverTimestamp()});
          firestore.collection("games/" + gameId + "/playersQueue").doc(playersId[0]).update({currentTurn: true});
        });
  }
}
