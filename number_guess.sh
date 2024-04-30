#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres --no-align --tuples-only -c"

NUMBER=$((RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME

USER_ID="$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")"

# if user not found
if [[ -z $USER_ID ]]
then
  # create new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT="$($PSQL "INSERT INTO users (username, games_played) VALUES ('$USERNAME', 0)")"
  # get new user info
  # USER="$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")"
else 
  # get user info
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = '$USER_ID'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = '$USER_ID'")
 
  # IFS='|' read -ra USER_DATA <<< "$USER"
  # GAMES_PLAYED="${USER_DATA[2]}"
  # BEST_GAME="${USER_DATA[3]}"
  # print welcome back message
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# get the user number guess
echo "Guess the secret number between 1 and 1000:"
read GUESS

# if not an integer, ask again
while [[ ! $GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS
done

# check if the guess is correct
TRIES=1
while [[ $GUESS != $NUMBER ]]
do
  # echo "guess = $GUESS number = $NUMBER tries = $TRIES" 
  (( TRIES++ ))
  # if the number is lower, try again
  if [[ $NUMBER -lt $GUESS ]]
  then
    echo "It's lower than that, guess again:" 
    read GUESS
  # if the number is higher, try again
  elif [[ $NUMBER -gt $GUESS ]]
  then
    echo "It's higher than that, guess again:" 
    read GUESS
  fi  
done

# echo success message
echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"

# if user has beaten their best game
if [[ -z $USER_BEST_GAME || $USER_BEST_GAME > $TRIES ]] 
then
  # update best game and total games
  UPDATE_USER_RESULT="$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = $TRIES WHERE username = '$USERNAME'")"
else 
  # otherwise only update total games
  UPDATE_USER_RESULT="$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")"
fi


