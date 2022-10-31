#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"
SECRET_NUMBER=$((1+$RANDOM%1000))
NUMBER_OF_TRIES=0
echo "Enter your username:"
read USERNAME
USERNAME_CHECK=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USERNAME_CHECK ]]
then
  USERNAME_INSERTED=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo "Guess the secret number between 1 and 1000:"
while [[ $GUESSED_NUMBER != $SECRET_NUMBER ]] 
do
read GUESSED_NUMBER
if ! [[ $GUESSED_NUMBER =~ ^[0-9]+$ ]]
then
  NUMBER_OF_TRIES=$((NUMBER_OF_TRIES+1))
  echo "That is not an integer, guess again:"
else
  if [[ $GUESSED_NUMBER > $SECRET_NUMBER ]]
  then
    NUMBER_OF_TRIES=$((NUMBER_OF_TRIES+1))
    echo "It's lower than that, guess again:"
  elif [[ $GUESSED_NUMBER < $SECRET_NUMBER ]]
  then
    NUMBER_OF_TRIES=$((NUMBER_OF_TRIES+1))
    echo "It's higher than that, guess again:"
  else 
    NUMBER_OF_TRIES=$((NUMBER_OF_TRIES+1))
    echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    INSERT_GAME_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED+1 WHERE username='$USERNAME'")
    if [[ $NUMBER_OF_TRIES < $BEST_GAME ]] || [[ -z $BEST_GAME ]]
    then
    BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_TRIES WHERE username='$USERNAME'")
    fi
  fi
fi
done

