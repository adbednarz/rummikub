import * as functions from "firebase-functions";
import {Game} from "./models/game";
import {firestore} from "./index";
import {QueryDocumentSnapshot} from "firebase-functions/lib/providers/firestore";

export class GameUtils {
  static createGame(
      transaction: FirebaseFirestore.Transaction,
      playerID: string, size: number): string {
    const gameRef: FirebaseFirestore.DocumentReference =
            firestore.collection("games").doc();

    transaction.set(gameRef,
        {isFull: false, size, players: {[playerID]: false}}
    );

    const titles = [];
    for (const color of ["black", "red", "orange", "blue"]) {
      for (let i = 1; i < 14; i++) {
        titles.push([i, color]);
      }
      if (color === "black" || color === "red") {
        titles.push([0, color]); // 0 === joker
      }
    }

    // the Fisher-Yates (aka Knuth) Shuffle
    /* for (let i = Object.entries(titles).length - 1; i > 0; i--) {
                  const j = Math.floor(Math.random() * (i + 1));
                  [titles[i], titles[j]] = [titles[j], titles[i]];
                }*/

    for (let i = 0; i < titles.length; i++) {
      transaction.set(
          gameRef.collection("pool").doc(),
          {[titles[i][0]]: titles[i][1]});
    }

    return gameRef.id;
  }

  static findGame(transaction: FirebaseFirestore.Transaction,
      size: number): Promise<FirebaseFirestore.QuerySnapshot> {
    return transaction.get(firestore.collection("games")
        .where("isFull", "==", false)
        .where("size", "==", size)
        .limit(1));
  }

  static addToGame(transaction: FirebaseFirestore.Transaction,
      playerID: string, gameResult: FirebaseFirestore.QuerySnapshot): string {
    const gameSnapshot: FirebaseFirestore.DocumentSnapshot =
            gameResult.docs[0];
    const game: Game = <Game> gameSnapshot.data();
    game.players[playerID] = false;
    const isFull = Object.keys(game.players).length == game.size;
    const newGameData: Game = {
      isFull, size: game.size, players: game.players,
    };
    transaction.update(gameSnapshot.ref, newGameData);

    return gameSnapshot.id;
  }

  static startGame(gameSnapshot: QueryDocumentSnapshot): void {
    const game: Game = <Game> gameSnapshot.data();
    if (game.isFull) {
      gameSnapshot.ref.collection("/pool")
          .limit(14 * game.size).get()
          .then((titlesResult) => {
            let counter = 0;
            for (const player of Object.keys(game.players)) {
              for (let i = 1; i < 15; i++) {
                functions.logger.log(titlesResult.docs[counter].data());
                const tileNumber = "titlesResult.docs[counter].data()[0]";
                const tileColor = "titlesResult.docs[counter].data()[1]";
                gameSnapshot.ref.collection("playersTiles")
                    .doc(player).collection("titles")
                    .add({[tileNumber]: tileColor})
                    .then(() => titlesResult.docs[counter].ref.delete());
                counter++;
              }
            }
          });
    }
  }
}
