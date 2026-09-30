#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RNG=$(( (RANDOM % 1000) + 1 ))
COUNT=0
echo "Enter your username:"
read USERNAME
USERNAME_PLAYED_CHECK=$($PSQL "SELECT username FROM game WHERE username='$USERNAME'")
if [[ -z $USERNAME_PLAYED_CHECK ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_USERNAME=$($PSQL "INSERT INTO game(username) VALUES('$USERNAME')")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM game WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM game WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS
((COUNT++))
while [[ $USER_GUESS != $RNG ]]
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif (( USER_GUESS > RNG ))
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read USER_GUESS
  ((COUNT+=1))
done

echo "You guessed it in $COUNT tries. The secret number was $RNG. Nice job!"
GAMES_PLAYED=$($PSQL "SELECT games_played FROM game WHERE username='$USERNAME'")
INCREMENT_GAMES_PLAYED=$((GAMES_PLAYED + 1))
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE game SET games_played = $INCREMENT_GAMES_PLAYED WHERE username = '$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM game WHERE username='$USERNAME'")
if [[ $COUNT < $BEST_GAME || $BEST_GAME == 0 ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE game SET best_game = $COUNT WHERE username='$USERNAME'")
fi
