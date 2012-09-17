void spray_ink( byte lower_nozzles, byte upper_nozzles) {
//lower_nozzles = 1-8  - PORTA
  for(int i = 0; i <= 7; i++){
    byte mask = 1<<i;
    if(lower_nozzles & mask){
      PORTA |= mask; delayMicroseconds(5);
      PORTA &= ~mask; delayMicroseconds(1);
    }
  } 
//upper_nozzles = 9-12 - PORTC using pins 4,5,6,7 so 4-7 not 0-3
  for(int i = 4; i <= 7; i++){
    byte mask = 1<<i;
    if(upper_nozzles<<3 & mask){
      PORTC |= mask; delayMicroseconds(5);
      PORTC &= ~mask; delayMicroseconds(1);
    }
  }
//wait to be sure we don't try to fire nozzles to fast and burn them out
  delayMicroseconds(800); 
}

