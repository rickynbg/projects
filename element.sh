
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"

ELEMENT_SELECT="SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, t.type, p.melting_point_celsius, p.boiling_point_celsius  FROM properties p LEFT JOIN elements e USING(atomic_number) LEFT JOIN types t USING(type_id)"


if [[ $1 ]]
then
  re='^[0-9]+$'
  if ! [[ $1 =~ $re ]]
  then
    if [[ ${#1} < 3 ]]
    then
      ELEMENT=$($PSQL "$ELEMENT_SELECT WHERE symbol='$1'")
    else
      ELEMENT=$($PSQL "$ELEMENT_SELECT WHERE name='$1'")
    fi
  else
    ELEMENT=$($PSQL "$ELEMENT_SELECT WHERE atomic_number=$1")
  fi
  
  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$ELEMENT" | while read ATOMIC_NUMBER BAR NAME BAR SYMBOL BAR ATOMIC_MASS BAR TYPE BAR MELT BAR BOIL
      do
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
      done
  fi
else
  echo "Please provide an element as an argument."
fi
