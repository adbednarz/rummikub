// import * as functions from "firebase-functions";
import {firestore} from "./index";
import {Game} from "./models/game";

export class GameUtils {
  static createGame(
      transaction: FirebaseFirestore.Transaction,
      playerID: string, size: number): string {
    const gameRef: FirebaseFirestore.DocumentReference =
        firestore.collection("games").doc();

    transaction.set(gameRef,
        {isFull: false, size, players: {[playerID]: false}}
    );

    for (const color of ["black", "red", "orange", "blue"]) {
      for (let i = 1; i < 14; i++) {
        for (let j = 0; j < 2; j++) {
          transaction.set(
              gameRef.collection("pool").doc(),
              {[i]: color});
        }
      }
      if (color === "black" || color === "red") {
        transaction.set(
            gameRef.collection("pool").doc(),
            {0: color}); // 0 === joker
      }
    }

    return gameRef.id;
  }

  static addToGame(transaction: FirebaseFirestore.Transaction, playerID: string,
      gameResult: FirebaseFirestore.QuerySnapshot): [string, Game] {
    const gameSnapshot: FirebaseFirestore.DocumentSnapshot =
        gameResult.docs[0];
    const game: Game = <Game> gameSnapshot.data();
    game.players[playerID] = false;
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

  static startGame(gameID: string, game: Game): void {
    firestore.runTransaction((transaction) => {
      return transaction.get(firestore.collection("games/" + gameID + "/pool")
          .limit(14 * game.size))
          .then((titlesResult) => {
            let counter = 0;
            for (const player of Object.keys(game.players)) {
              for (let i = 1; i < 15; i++) {
                const titleDocument = titlesResult.docs[counter];
                const tileNumber = Object.keys(titleDocument.data())[0];
                const tileColor = Object.values(titleDocument.data())[0];
                transaction.set(firestore.collection("games/" + gameID + "/playersTiles")
                    .doc(player).collection("titles").doc(), {[tileNumber]: tileColor});
                transaction.delete(titleDocument.ref);
                counter++;
              }
            }
          });
    }).then(() => firestore.collection("games").doc(gameID).get()
        .then((snap) => {
          const players: {[p: string]: boolean} = snap.get("players");
          players[Object.keys(players)[0]] = true;
          snap.ref.update({players: players});
        }));
  }
}
