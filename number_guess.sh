#!/bin/bash

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"
USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USERNAME_ID ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=0

  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id='$USERNAME_ID'")
  BEST_GAMES=$($PSQL "SELECT best_game FROM users WHERE user_id='$USERNAME_ID'")
  
  echo -e "Welcome back, $USERNAME! You have played $(($GAMES_PLAYED)) games, and your best game took $(($BEST_GAMES)) guesses."
fi

echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0

MESSAGE(){
  if [[ $1 ]]
  then
    echo -e "$1"
  fi

  read NUMBER_GUESS
  if [[ ! $NUMBER_GUESS =~ ^[0-9]+$ ]]
  then
    MESSAGE "That is not an integer, guess again:"
  else
    if [[ $NUMBER_GUESS > $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $NUMBER_GUESS < $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
  fi
}

while [[ $NUMBER_GUESS != $SECRET_NUMBER ]]
do
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
  MESSAGE
done

UPDATE_USER=$($PSQL "UPDATE users SET games_played = $(($GAMES_PLAYED + 1)) WHERE user_id = $USERNAME_ID")
UPDATE_USER=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE user_id = $USERNAME_ID")

echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"