import {firestore} from "./index";
import * as functions from "firebase-functions";
import {DocumentSnapshot} from "firebase-functions/lib/providers/firestore";

export class GameUtils {
  static checkAuthentication(playerId: string | undefined): string {
    if (playerId) {
      return playerId;
    } else {
      throw new functions.https.HttpsError("failed-precondition",
          "The function must be called while authenticated.");
    }
  }

  static createGame(transaction: FirebaseFirestore.Transaction,
      playerId: string, playerName: string, available: number, size: number, timeForMove: number): string {
    const gameRef: FirebaseFirestore.DocumentReference = firestore.collection("games").doc();

    transaction.set(gameRef, {available: available, currentTurn: "", size: size, timeForMove: timeForMove});

    transaction.set(
        gameRef.collection("playersQueue").doc(playerId),
        {initialMeld: false, name: playerName}
    );

    for (const color of ["black", "red", "orange", "blue"]) {
      for (let i = 1; i < 14; i++) {
        for (let j = 0; j < 2; j++) {
          transaction.set(
              gameRef.collection("pool").doc(),
              {color: color, number: i});
        }
      }
      if (color === "black" || color === "red") {
        transaction.set(
            gameRef.collection("pool").doc(),
            {color: color, number: 0}); // 0 === joker
      }
    }

    return gameRef.id;
  }

  static addToGame(transaction: FirebaseFirestore.Transaction, playerId: string, playerName: string,
      gameDoc: DocumentSnapshot): [string, boolean] {
    transaction.set(
        gameDoc.ref.collection("playersQueue").doc(playerId),
        {initialMeld: false, name: playerName}
    );
    const availablePlaces: number = gameDoc.get("available") - 1;
    if (availablePlaces > 0) {
      transaction.update(gameDoc.ref, {available: availablePlaces});
      return [gameDoc.id, false];
    } else {
      return [gameDoc.id, true];
    }
  }

  static findGame(size: number, timeForMove: number): FirebaseFirestore.Query {
    return firestore.collection("games")
        .where("available", ">", 0)
        .where("size", "==", size)
        .where("timeForMove", "==", timeForMove)
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
          for (const playerId of playersId) {
            for (let i = 1; i < 15; i++) {
              const tileDocument = tilesDoc.docs[counter];
              firestore.collection("games/" + gameId + "/playersRacks/" + playerId + "/rack").doc()
                  .set({color: tileDocument.data()["color"], number: tileDocument.data()["number"]});
              tileDocument.ref.delete();
              counter++;
            }
          }
          firestore.collection("games/").doc(gameId).update({available: 0, currentTurn: playersId[0]});
        });
  }
}
