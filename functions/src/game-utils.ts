// import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {firestore} from "./index";
import {Game, Player} from "./models/game";
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

    transaction.set(
        gameRef,
        {isFull: false, size, players: {[playerId]: {currentTurn: false, initialMeld: false}}}
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
      gameResult: FirebaseFirestore.QuerySnapshot): [string, Game] {
    const gameSnapshot: FirebaseFirestore.DocumentSnapshot =
        gameResult.docs[0];
    const game: Game = <Game> gameSnapshot.data();
    game.players[playerId] = {currentTurn: false, initialMeld: false};
    const isFull = Object.keys(game.players).length == game.size;
    const newGameData: Game = {
      isFull, size: game.size, players: game.players,
    };
    transaction.update(gameSnapshot.ref, newGameData);

    return [gameSnapshot.id, newGameData];
  }

  static findGame(size: number): FirebaseFirestore.Query {
    return firestore.collection("games")
        .where("isFull", "==", false)
        .where("size", "==", size)
        .limit(1);
  }

  static startGame(gameId: string, game: Game): void {
    firestore.runTransaction((transaction) => {
      return transaction.get(firestore.collection("games/" + gameId + "/pool")
          .limit(14 * game.size))
          .then((titlesResult) => {
            let counter = 0;
            for (const player of Object.keys(game.players)) {
              for (let i = 1; i < 15; i++) {
                const titleDocument = titlesResult.docs[counter];
                const tileColor = Object.keys(titleDocument.data())[0];
                const tileNumber = Object.values(titleDocument.data())[0];
                transaction.set(firestore.collection("games/" + gameId + "/playersTiles")
                    .doc(player).collection("tiles").doc(), {[tileColor]: tileNumber});
                transaction.delete(titleDocument.ref);
                counter++;
              }
            }
          });
    }).then(() => firestore.collection("games").doc(gameId).get()
        .then((snap) => {
          const players: {[p: string]: Player} = snap.get("players");
          players[Object.keys(players)[0]] = {currentTurn: true, initialMeld: false};
          snap.ref.update({players: players, timer: admin.firestore.FieldValue.serverTimestamp()});
        }));
  }
}
