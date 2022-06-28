#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
                do
if [[ $WINNER != winner ]]
then
# check for existing winner
CHECK_W=$($PSQL "SELECT name FROM teams WHERE name IN ('$WINNER')")
# if no winner
if [[ -z $CHECK_W ]]
then
# insert winner
INSERT_W=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
if [[ $INSERT_W == "INSERT 0 1" ]]
then
echo Inserted into teams: $WINNER
fi
fi
#check for existing loser
CHECK_L=$($PSQL "SELECT name FROM teams WHERE name IN ('$OPPONENT')")
if [[ -z $CHECK_L ]]
then
# insert loser
INSERT_L=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
if [[ $INSERT_L == "INSERT 0 1" ]]
then
echo Inserted into teams: $OPPONENT
fi
fi
fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
                do
if [[ $YEAR != year ]]
then
WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
CHECK_GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID")
#if no match
if [[ -z $CHECK_GAME_ID ]]
then
#insert match data
WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
INSERT_MATCH=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
if [[ $INSERT_MATCH == "INSERT 0 1" ]]
then
echo Inserted into games: $YEAR - $WINNER V $OPPONENT
fi
fi
fi
done
