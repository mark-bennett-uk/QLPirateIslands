  10 REM *********************
  20 REM *  Pirate Islands   *
  30 REM *      V1.0.0       *
  40 REM * Mark Bennett 2022 *
  50 REM *********************

 100 CLEAR
 110 RANDOMISE
 120 initialise_game
 125 set_up_windows
 130 reset_game
 140 reset_players
 150 reset_dice
 170 player_set_up

 300 REPEAT games
 310   reset_game
 320   REPEAT game_loop
 330     reset_dice
 340     print_dice
 350     display_player_name

 360     REPEAT until_end_turn
 370       IF 13 - dice_used + empty_island < 3 THEN
 380         PRINT #0, player_name$(player) ! "turn over"
 390         EXIT until_end_turn
 400       END IF
 410       select_dice
 420       roll_dice
 430       print_dice
 440       IF navy >= 3 THEN
 450         PRINT #0, player_name$(player) ! "treasure confiscated"
 455         sound 3
 460         clear_islands
 470         EXIT until_end_turn
 480       END IF
 490       IF player_type(player) = 2 THEN
 500         REM ***** computer player move 
 
 510         IF max_score >= 13 THEN
 520           IF score(player) + treasure <= max_score THEN 
 530             key$ = "c"
 540           ELSE
 550             IF navy = 0 THEN
 560               key$ = "c"
 570             ELSE
 580               key$ = "s"
 590             END IF 
 600           END IF
 610         ELSE
 620           IF navy = 0 OR treasure = 0 THEN 
 630             key$ = "c"
 640           ELSE 
 650             IF navy = 1 THEN 
 660               IF RND(2) = 1 THEN
 670                 key$ = "s"
 680               ELSE
 690                 key$ = "c"
 700               END IF
 710             END IF
 720             IF navy > 1 THEN 
 730               key$ = "s"
 740             END IF
 750           END IF
 760         END IF 
 770         IF key$ = "c" THEN
 780           PRINT #0, player_name$(player) ! "continues."
 790         ELSE
 800           PRINT #0, player_name$(player) ! "stops."
 810         END IF

 820       ELSE
 830         REM ***** human player move 
 840         INPUT #0, player_name$(player) & " stop or continue?(S or C)" ! key$
 850       END IF
 860       IF key$ = "S" OR key$ = "s" THEN EXIT until_end_turn
 865       sound 1
 870       clear_islands
 
 880     END REPEAT until_end_turn
 885     sound 2

 890     clear_islands
 900     move_ship 4
 910     ship_position = 0
  
 920     enter_score
 930     print_score
 940     IF player = player_count - 1 AND max_score >= 13 THEN EXIT game_loop
 950     REM ***** next player
 960     player = player + 1
 970     IF player > player_count - 1 THEN player = 0
 980   END REPEAT game_loop
 981   print_winner
 982   INPUT #0, "Enter to play again, Q to Quit" ! l$
 983   IF l$ = "q" OR l$ = "Q" THEN EXIT games
 984   clear_islands
 985   clear_scores
 990 END REPEAT games

1000 DEF PROC select_dice
1010   LOCAL i, die_number, dice_needed, die_id, dice_free
1020   IF empty_island < 3 THEN
1030     LET dice_needed = 3 - empty_island
1040     FOR i = 1 TO dice_needed
1050       LET dice_free = 13 - dice_used - i
1060       die_number = RND(dice_free)
1070       die_id = 0
1080       REPEAT until_first_die_available
1090         IF dice_flag(die_id) = 0 THEN EXIT until_first_die_available
1100         die_id = die_id + 1
1110       END REPEAT until_first_die_available
1120       REPEAT until_die_picked
1130         IF die_number = 0 THEN
1140           dice_flag(die_id) = 1
1150           EXIT until_die_picked
1160         END IF
1170         REPEAT until_die_available
1180           die_id = die_id + 1
1190           IF dice_flag(die_id) = 0 THEN EXIT until_die_available
1200         END REPEAT until_die_available
1210         die_number = die_number - 1
1220       END REPEAT until_die_picked
1230     NEXT i
1240   END IF
1290 END DEF select_dice

1300 DEF PROC roll_dice
1310   LOCAL i, die_side, result$
1320   empty_island = 0
1330   FOR i = 0 TO 12
1340     IF dice_flag(i) = 1 OR dice_flag(i) = 2 THEN
1350       SELECT ON ship_position
1360         ON ship_position = 0 
1370           ship_position = 1
1380           move_ship 1
1390         ON ship_position = 1
1400           ship_position = 2
1410           move_ship 2
1420         ON ship_position = 2
1430           ship_position = 3
1440           move_ship 2
1450         ON ship_position = 3  
1460           ship_position = 1
1470           move_ship 5
1480       END SELECT
1490       die_side = RND(5) + 1
1500       result$ = dice$(i)(die_side)
1510       IF dice_flag(i) = 1 THEN dice_used = dice_used + 1
1520       IF result$ = "I" THEN 
1530         dice_flag(i) = 2
1540         empty_island = empty_island + 1
1550         PAUSE 50
1555         sound 2
1560       END IF
1570       IF result$ = "N" THEN 
1580         dice_flag(i) = 3
1590         navy = navy + 1
1600         draw_graphic 8, (ship_position - 1) * 120 + 40, 110
1610         print_dice
1615         sound 1
1620       END IF
1630       IF result$ = "T" THEN 
1640         dice_flag(i) = 4
1650         treasure = treasure + 1
1660         draw_graphic 7, (ship_position - 1) * 120 + 40, 110
1670         print_dice
1675         sound 0
1680       END IF
1690     END IF
1700   NEXT i
1790 END DEF roll_dice

1800 DEF PROC print_dice
1810   LOCAL i
1820   AT #3, 5, 8
1830   INK #3, 6
1840   PRINT #3, treasure; "  ";
1850   AT #3, 7, 8
1860   INK #3, 2
1870   PRINT #3, navy; "  ";
1880   INK #3, 1
1890 END DEF print_dice

1900 DEF PROC enter_score
1910   IF navy < 3 THEN
1920     score(player) = score(player) + treasure
1930   END IF
1940   IF score(player) > max_score THEN max_score = score(player)
1990 END DEF enter_score

2000 DEF PROC print_score
2010   AT #4, player + 5, 8 - (score(player) > 9);
2020   PRINT #4; score(player)
2090 END DEF print_score

2100 DEF PROC print_winner
2110   LOCAL i
2120   PRINT #0, "Game over, winner was ";
2130   FOR i = 0 TO 9
2140     IF score(i) = max_score THEN PRINT #0; player_name$(i); " ";
2150   NEXT i
2160   PRINT #0
2190 END DEF print_winner

2200 DEF PROC draw_graphic(n, x, y)
2210   REM n = id of graphic 1 is first graphic
2220   REM x = global position from left edge of screen, 2 per pixel in 8 colour mode
2230   REM x must be multiple of 8 e.g. 0,8,16,24 etc
2240   REM y = global position down from the top of the screen
2250   LOCAL screen_base, start_byte, i, j, k, l
2260   LET screen_base = 131072
2270   LET start_byte = screen_base + (x / 4) + (y * 128)
2280   LET l = (n - 1) * 21
2290   FOR i = 0 TO 20
2300     LET k = i * 128
2310     FOR j = 0 TO 3
2320       POKE_W start_byte + k + (j * 2), graphics_data(l + i, j)
2330     NEXT j
2340   NEXT I
2390 END DEF draw_graphic

2400 DEF PROC display_player_name
2410   AT #3, 3, 8;
2420   PRINT #3; player_name$(player); FILL$(" ", 16 - LEN(player_name$(player)))
2490 END DEF display_player_name

2500 DEF PROC move_ship(m)
2510   LOCAL i
2520   REM base to island 1
2530   IF m = 1 THEN
2540     FOR i = 1 TO 20
2550       PAN #6, -12
2560     NEXT i
2570     FOR i = 1 TO 5
2580       SCROLL #6, -4
2590     NEXT i
2600   END IF
2610   REM island 1 to island 2 or island 2 to island 3
2620   IF m = 2 THEN
2630     FOR i = 1 TO 10
2640       PAN #6, 12
2650     NEXT i
2660   END IF
2670   REM island 3 to base
2680   IF m = 4 THEN
2690     FOR i = 1 TO 5
2700       SCROLL #6, 4
2710     NEXT i
2720   END IF
2730   REM island 3 to island 1
2740   IF m = 5 THEN
2750     FOR i = 1 TO 3
2755       SCROLL #6, 4
2757     NEXT i
2760     FOR i = 1 TO 20
2770       PAN #6, -12
2780     NEXT i
2790     FOR i = 1 TO 3
2795       SCROLL #6, -4
2797     NEXT i
2800   END IF
2890 END DEF move_ship

3000 DEF PROC clear_islands
3010   BLOCK #5, 32, 21, 40, 30, 1
3020   BLOCK #5, 32, 21, 160, 30, 1
3030   BLOCK #5, 32, 21, 280, 30, 1
3090 END DEF clear_islands

3100 DEF PROC clear_scores
3110   LOCAL i
3120   FOR i = 1 TO player_count
3130     AT #4, i + 4, 7;
3140     PRINT #4; " 0"
3150   NEXT i
3190 END DEF clear_scores

3200 DEF PROC display_instructions
3210   CLS #1
3220   PRINT #1, "Pirate Islands Instructions"
3230   PRINT #1
3240   INK #1, 6 : PRINT #1, "Collect as much treasure as you can  without getting caught."
3260   INK #1, 5 : PRINT #1, "Up to 10 players take turns to visit 3 islands, each may be empty, have   treasure or a navy patrol."
3270   INK #1, 4 : PRINT #1, "You choose when to stop visiting     islands, try to get the most treasurewithout getting caught 3 times."
3273   INK #1, 6 : PRINT #1, "If you do, they confiscate your      treasure and your turn ends."
3280   INK #1, 5 : PRINT #1, "The first player that gets to 13     treasures triggers the end of the    game, the remaining players get to   carry on until all have had the same number of turns."
3290   INK #1, 4 : PRINT #1, "Pirate with the most treasure wins."
3295 END DEF display_instructions

5000 DEF PROC set_up_windows
5010   OPEN #3, scr_512x80a0x0
5020   PAPER #3, 5 :  INK #3, 1 : CLS #3
5030   OPEN #4, scr_128x215a384x0
5040   PAPER #4, 6 :  INK #4, 1 : CLS #4
5050   OPEN #5, scr_384x60a0x80
5060   PAPER #5, 1 :  INK #5, 6 : CLS #5
5070   BLOCK #5, 384, 10, 0, 0, 5
5080   OPEN #6, scr_384x75a0x140
5090   PAPER #6, 1 :  INK #6, 6 : CLS #6
5100   AT #3, 1, 2 : PRINT #3, "PIRATE ISLANDS"
5110   draw_graphic 1, 40, 42
5120   draw_graphic 2, 24, 66
5130   draw_graphic 3, 56, 66
5140   AT #4, 2, 1 : PRINT #4, "Pirates"
5150   draw_graphic 4, 40, 113
5160   draw_graphic 5, 72, 113
5170   draw_graphic 6, 72, 92
5180   draw_graphic 4, 160, 113
5190   draw_graphic 5, 192, 113
5200   draw_graphic 6, 192, 92
5210   draw_graphic 4, 280, 113
5220   draw_graphic 5, 312, 113
5230   draw_graphic 6, 312, 92
5240   draw_graphic 9, 288, 167
5250   draw_graphic 10, 320, 167
5260   draw_graphic 11, 288, 188
5270   draw_graphic 12, 320, 188
5290 END DEF set_up_windows

6000 DEF PROC sound(n)
6010   REM n = sound number
6020   SELECT ON n
6030     ON n = 0 
6040       BEEP 694,6,26,1666,4,0,8,15
6050     ON n = 1 
6060       BEEP 694,17,35,1666,11,0,8,15
6070     ON n = 2 
6080       BEEP 694,34,52,277,11,0,8,15
6090     ON n = 3 
6100       BEEP 2777,42,90,277,6,0,0,0
6180   END SELECT
6190 END DEF sound

8000 DEF PROC load_graphic_data(n)
8010   REM n = number of graphics to load
8020   LOCAL i, j, k, l
8030   RESTORE
8040   DIM graphics_data((n - 1) * 21 + 20, 3)
8050   FOR i = 0 TO n - 1
8060     LET l = i * 21
8070     AT #0, 0, 22
8080     PRINT #0, 12 - i; " ";
8090     FOR j = 0 TO 20
8100       FOR k = 0 TO 3
8110         READ graphics_data(l + j, k)
8120       NEXT k
8130     NEXT j
8140   NEXT i
8150   PRINT #0
8190 END DEF load_graphic_data

8200 DATA 43605,255,255,765
8201 DATA 41055,92,15,525
8202 DATA 41053,112,12,2613
8203 DATA 32885,192,48,2613
8204 DATA 32885,192,48,10965
8205 DATA 32887,0,48,10965
8206 DATA 215,32896,195,43541
8207 DATA 215,41096,202,43685
8208 DATA 2778,43690,10986,41641
8209 DATA 255,2299,255,32955
8210 DATA 213,630,85,32923
8211 DATA 213,630,85,32923
8212 DATA 213,117,93,32923
8213 DATA 213,117,93,32919
8214 DATA 213,117,93,87
8215 DATA 213,117,85,87
8216 DATA 213,117,85,87
8217 DATA 213,117,85,87
8218 DATA 213,117,85,8359
8219 DATA 213,2682,32790,41127
8220 DATA 255,2810,32958,43179

8221 DATA 43605,41561,43605,43605
8222 DATA 43605,43094,43605,43605
8223 DATA 43605,43094,43605,43605
8224 DATA 43605,32832,0,0
8225 DATA 43605,35397,43605,43605
8226 DATA 43605,35397,43605,43605
8227 DATA 43605,34884,34884,34884
8228 DATA 43092,513,8721,85
8229 DATA 43092,2052,85,43622
8230 DATA 43605,85,43673,33429
8231 DATA 32853,43622,43622,43622
8232 DATA 2649,43673,43673,43673
8233 DATA 8293,2133,598,598
8234 DATA 10841,43673,43673,43673
8235 DATA 10854,43622,43622,43622
8236 DATA 8279,2297,597,87
8237 DATA 8813,41566,43622,41581
8238 DATA 8797,8925,43673,41629
8239 DATA 605,8413,85,605
8240 DATA 41565,41565,43605,41565
8241 DATA 43095,2805,43605,43095

8242 DATA 43605,43605,43605,43605
8243 DATA 43605,43605,43605,43605
8244 DATA 43605,43605,43605,43605
8245 DATA 0,43605,43605,43605
8246 DATA 43092,0,0,0
8247 DATA 43605,43605,43605,43092
8248 DATA 85,8785,43605,43092
8249 DATA 43622,2116,34884,34884
8250 DATA 43673,8785,8721,8208
8251 DATA 598,2116,0,0
8252 DATA 43673,577,43605,43605
8253 DATA 43622,10837,43605,43605
8254 DATA 597,10837,43605,43605
8255 DATA 43622,10837,43605,43605
8256 DATA 43673,10837,43605,43605
8257 DATA 758,10837,43605,43605
8258 DATA 41565,10837,43605,43605
8259 DATA 8926,10837,43605,43605
8260 DATA 8413,10837,43605,43605
8261 DATA 41565,43605,43605,43605
8262 DATA 2805,43605,43605,43605

8263 DATA 85,85,85,85
8264 DATA 85,85,85,85
8265 DATA 85,85,85,85
8266 DATA 85,85,85,85
8267 DATA 85,85,85,85
8268 DATA 85,85,85,85
8269 DATA 85,85,85,85
8270 DATA 85,85,85,85
8271 DATA 85,85,85,85
8272 DATA 85,85,85,85
8273 DATA 85,85,85,85
8274 DATA 85,85,85,85
8275 DATA 85,85,85,85
8276 DATA 85,85,85,85
8277 DATA 85,85,85,85
8278 DATA 85,85,85,85
8279 DATA 85,85,85,85
8280 DATA 85,85,85,85
8281 DATA 598,43690,43690,43690
8282 DATA 10858,43690,43690,43690
8283 DATA 43690,43690,43690,43690

8284 DATA 85,85,109,85
8285 DATA 85,85,121,85
8286 DATA 85,85,237,85
8287 DATA 85,85,181,85
8288 DATA 85,85,229,85
8289 DATA 85,85,181,85
8290 DATA 85,85,229,85
8291 DATA 85,87,181,85
8292 DATA 85,86,213,85
8293 DATA 85,87,149,85
8294 DATA 85,86,213,85
8295 DATA 85,87,149,85
8296 DATA 85,94,213,85
8297 DATA 85,91,85,85
8298 DATA 85,94,85,85
8299 DATA 85,91,85,85
8300 DATA 85,94,85,85
8301 DATA 85,91,85,85
8302 DATA 32917,10858,43690,32917
8303 DATA 43690,43690,43690,43177
8304 DATA 43690,43690,43690,43690

8305 DATA 85,85,85,85
8306 DATA 85,85,85,85
8307 DATA 85,85,85,85
8308 DATA 85,85,85,85
8309 DATA 85,85,85,85
8310 DATA 85,85,85,85
8311 DATA 596,40965,85,10305
8312 DATA 85,43009,85,43520
8313 DATA 85,2640,596,32789
8314 DATA 85,596,35344,85
8315 DATA 596,40965,43009,85
8316 DATA 85,43520,10305,43009
8317 DATA 85,2640,43520,43520
8318 DATA 85,85,43520,596
8319 DATA 85,85,10305,85
8320 DATA 85,596,43520,32789
8321 DATA 85,10816,43520,43009
8322 DATA 85,43009,109,10816
8323 DATA 596,32789,121,85
8324 DATA 596,85,109,85
8325 DATA 85,85,121,85

8326 DATA 85,85,85,85
8327 DATA 85,85,85,85
8328 DATA 85,85,85,85
8329 DATA 85,85,85,85
8330 DATA 85,85,85,85
8331 DATA 85,85,85,85
8332 DATA 85,85,85,85
8333 DATA 85,80,0,1
8334 DATA 85,2629,20,81
8335 DATA 85,2116,84,69
8336 DATA 85,10260,81,69
8337 DATA 85,8209,32929,21
8338 DATA 85,8722,41632,32949
8339 DATA 85,0,8224,32897
8340 DATA 85,10773,10789,41105
8341 DATA 85,10773,10276,41041
8342 DATA 85,10773,10773,41041
8343 DATA 85,10773,10773,41041
8344 DATA 85,10773,10773,41041
8345 DATA 85,10773,10773,41105
8346 DATA 85,0,8738,41121

8347 DATA 85,85,85,85
8348 DATA 85,85,85,85
8349 DATA 85,85,85,85
8350 DATA 85,85,85,85
8351 DATA 85,85,85,85
8352 DATA 85,85,85,85
8353 DATA 85,85,85,85
8354 DATA 85,85,85,85
8355 DATA 85,85,85,85
8356 DATA 85,85,85,85
8357 DATA 85,85,85,85
8358 DATA 85,85,85,85
8359 DATA 85,85,85,85
8360 DATA 85,86,85,85
8361 DATA 85,80,0,1
8362 DATA 85,64,0,1
8363 DATA 85,2650,43690,1
8364 DATA 85,43690,43690,85
8365 DATA 598,35514,41646,85
8366 DATA 598,734,32951,85
8367 DATA 85,117,93,85

8368 DATA 85,85,43707,85
8369 DATA 85,85,43758,85
8370 DATA 2651,43193,85,85
8371 DATA 2654,43245,43707,32917
8372 DATA 2651,43193,43758,33494
8373 DATA 2654,43245,43707,33431
8374 DATA 2651,43193,43758,33495
8375 DATA 2654,43245,43707,33431
8376 DATA 85,85,43758,32981
8377 DATA 10862,32981,43707,33430
8378 DATA 10875,32917,85,599
8379 DATA 10862,35547,43707,41655
8380 DATA 10875,35486,33474,41703
8381 DATA 10862,35032,33411,8759
8382 DATA 10875,35486,0,41703
8383 DATA 85,2651,33411,41655
8384 DATA 221,2782,10284,41189
8385 DATA 187,2232,43707,8245
8386 DATA 238,2798,43758,41189
8387 DATA 187,185,85,85
8388 DATA 238,237,85,85

8389 DATA 85,85,85,85
8390 DATA 41141,85,85,85
8391 DATA 41189,85,85,85
8392 DATA 85,85,85,85
8393 DATA 43245,85,85,85
8394 DATA 43193,85,85,85
8395 DATA 43245,85,85,85
8396 DATA 43193,85,85,85
8397 DATA 85,85,85,85
8398 DATA 43758,85,85,85
8399 DATA 43707,85,85,85
8400 DATA 43758,85,85,85
8401 DATA 43707,85,85,85
8402 DATA 43758,85,85,85
8403 DATA 43707,85,85,85
8404 DATA 43758,85,85,85
8405 DATA 85,85,85,85
8406 DATA 153,149,85,85
8407 DATA 221,213,85,85
8408 DATA 187,149,85,85
8409 DATA 238,213,85,85

8410 DATA 187,187,187,187
8411 DATA 110,238,238,238
8412 DATA 123,121,183,155
8413 DATA 110,238,238,238
8414 DATA 91,187,187,187
8415 DATA 85,238,238,238
8416 DATA 85,85,85,85
8417 DATA 85,85,85,85
8418 DATA 85,85,85,85
8419 DATA 85,85,85,85
8420 DATA 85,85,85,85
8421 DATA 85,85,85,85
8422 DATA 85,85,85,85
8423 DATA 85,85,85,85
8424 DATA 85,85,85,85
8425 DATA 85,85,85,85
8426 DATA 85,85,85,85
8427 DATA 85,85,85,85
8428 DATA 85,85,85,85
8429 DATA 85,85,85,85
8430 DATA 85,85,85,85

8431 DATA 187,149,85,85
8432 DATA 238,213,85,85
8433 DATA 123,85,85,85
8434 DATA 238,85,85,85
8435 DATA 185,85,85,85
8436 DATA 237,85,85,85
8437 DATA 85,85,85,85
8438 DATA 85,85,85,85
8439 DATA 85,85,85,85
8440 DATA 85,85,85,85
8441 DATA 85,85,85,85
8442 DATA 85,85,85,85
8443 DATA 85,85,85,85
8444 DATA 85,85,85,85
8445 DATA 85,85,85,85
8446 DATA 85,85,85,85
8447 DATA 85,85,85,85
8448 DATA 85,85,85,85
8449 DATA 85,85,85,85
8450 DATA 85,85,85,85
8451 DATA 85,85,85,85

9000 DEF PROC player_set_up
9010   LOCAL key$, name$, player_id
9020   LET name$ = ""
9030   LET player_id = 1
9040   LET key$ = ""
9050   LET stop_message$ = ""
9060   CLS #4
9070   AT #4, 2, 1 : PRINT #4, "Pirates"
9080   REPEAT until_end_of_players
9090     REPEAT until_type_accepted
9100       INPUT #0, "Pirate " & player_id & " Human or Comp" & stop_message$ & "?" ! key$
9110       IF key$ = "H" OR key$ = "C" OR key$ = "h" OR key$ = "c" OR key$ = "X" OR key$ = "x" THEN EXIT until_type_accepted
9120     END REPEAT until_type_accepted
9130     IF player_id > 2 AND (key$ = "X" OR key$ = "x") THEN EXIT until_end_of_players
9140     player_type(player_id - 1) = 2
9150     IF key$ = "H" OR key$ = "h" THEN 
9160       player_type(player_id - 1) = 1
9170       REPEAT until_name_accepted
9180         INPUT #0, "Pirate " & player_id & " Name?" ! name$
9190         IF name$ <> "" THEN EXIT until_name_accepted
9200       END REPEAT until_name_accepted
9210       IF LEN(name$) > 14 THEN name$ = name$(1 TO 14)
9220       player_name$(player_id - 1) = name$
9230     END IF
9240     IF player_id = 2 THEN stop_message$ = " (x = stop)"
9250     IF player_type(player_id - 1) = 1 THEN INK #4, 0 
9260     IF player_type(player_id - 1) = 2 THEN INK #4, 1
9270     AT #4, 4 + player_id, 0 + player_id < 10
9280     PRINT #4; player_id; " "; player_name$(player_id - 1)(1 TO 3); "  0"
9290     player_id = player_id + 1
9300     IF player_id = 11 THEN EXIT until_end_of_players
9310   END REPEAT until_end_of_players
9320   player_count = player_id - 1
9390 END DEF player_set_up

9400 DEF PROC reset_game
9410   LOCAL i
9420   LET player = 0
9430   LET max_score = 0
9440   FOR i = 0 TO 9
9450     score(i) = 0
9460   NEXT i
9470   LET ship_position = 0
9490 END DEF reset_game

9500 DEF PROC reset_players
9510   LET player_count = 0
9520   player_name$(0) = "Black Beard"
9521   player_name$(1) = "Jack Sparrow"
9522   player_name$(2) = "Pugwash"
9523   player_name$(3) = "LeChuck"
9524   player_name$(4) = "Captain Kidd"
9525   player_name$(5) = "Flint"
9526   player_name$(6) = "Hook"
9527   player_name$(7) = "Grace O’Malley"
9528   player_name$(8) = "Long John Silver"
9529   player_name$(9) = "Red Beard"
9590 END DEF reset_players

9600 DEF PROC reset_dice
9610   LOCAL i
9620   FOR i = 0 TO 12
9630     dice_flag(i) = 0
9640   NEXT i
9650   LET dice_used = 0
9660   LET navy = 0
9670   LET treasure = 0
9680   LET empty_island = 0
9690 END DEF reset_dice

9800 DEF PROC initialise_game
9802   LOCAL dump$
9805   MODE 8
9810   PAPER #0, 0 : INK #0, 7 : CLS #0
9811   PAPER #1, 0 : INK #1, 7 : CLS #1
9812   PAPER #2, 0 : INK #2, 7 : CLS #2
9820   DIM score(9)
9822   DIM player_type(9) : REM 1 = human 2 = computer
9824   DIM player_name$(9, 16)
9826   DIM dice$(12, 7)
9827   DIM dice_flag(12) : REM 0 = available 1 = chosen 2 = empty island 3 = navy 4 = treasure
9830   dice$(0) = "TTTIING"
9831   dice$(1) = "TTTIING"
9832   dice$(2) = "TTTIING"
9833   dice$(3) = "TTTIING"
9834   dice$(4) = "TTTIING"
9835   dice$(5) = "TTTIING"
9836   dice$(6) = "TTIINNY"
9837   dice$(7) = "TTIINNY"
9838   dice$(8) = "TTIINNY"
9839   dice$(9) = "TTIINNY"
9840   dice$(10) = "TIINNNR"
9841   dice$(11) = "TIINNNR"
9842   dice$(12) = "TIINNNR"
9850   display_instructions
9852   PRINT #0, "Creating graphics ... "
9854   load_graphic_data 12
9856   CLS #0
9860   sound 0
9870   INPUT #0, "Press enter to play" ! dump$
9880   CLS #0
9890 END DEF initialise_game

9900 DEF PROC reset
9910   MODE 4
9920   PAPER 0 : INK 7
9930   CLS
9940 END DEF reset
