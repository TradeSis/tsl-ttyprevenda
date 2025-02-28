/* helio 112022 - campanha seguro prestamista gratis */
DEFINE INPUT-OUTPUT PARAMETER resposta   AS LOGICAL   NO-UNDO.
DEFINE INPUT        PARAMETER pergunta AS CHARACTER NO-UNDO.
DEFINE INPUT        PARAMETER titulo   AS CHARACTER NO-UNDO.
DEFINE INPUT        PARAMETER positivo AS CHARACTER NO-UNDO.
DEFINE INPUT        PARAMETER negativo AS CHARACTER NO-UNDO.

DEFINE VARIABLE d AS INTEGER NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE j AS INTEGER NO-UNDO.
DEFINE VARIABLE msg AS CHARACTER format "x(10)" EXTENT 20 NO-UNDO.

DEFINE VARIABLE new_lang AS CHARACTER format "x(10)"
            EXTENT 2 NO-UNDO INITIAL [
   "  Sim  ",
   "  Nao " ].
if positivo <> ""
then new_lang[1] = positivo.
if negativo <> ""
then new_lang[2] = negativo.

bell.

FORM
  SPACE(2) pergunta FORMAT "x(40)" SPACE(2) SKIP
  WITH FRAME dbox-bot OVERLAY NO-LABELS NO-ATTR-SPACE
  d + 4 DOWN CENTERED ROW MAXIMUM(3,(SCREEN-LINES - d) / 2 - 3)

  COLOR messages
   title titulo.

FORM
  SPACE(10) msg[1] FORMAT "x(10)" SPACE(6) msg[2] FORMAT "x(10)" SKIP
  WITH FRAME dbox-top OVERLAY NO-LABELS ATTR-SPACE NO-BOX
  WIDTH 40 CENTERED ROW MAXIMUM(6,(SCREEN-LINES - d) / 2) + d
  COLOR messages.

ASSIGN
  d      = 1
  msg[d] = pergunta.
DO WHILE (LENGTH(msg[d]) > 40 OR INDEX(msg[d],"!") > 0) AND d < 20:

  ASSIGN
    i          = MAXIMUM(
                 R-INDEX(SUBSTRING(msg[d],1,40)," "),
                 R-INDEX(SUBSTRING(msg[d],1,40),","))
    i          = (IF i = 0 THEN 40 ELSE i)
    j          = (IF INDEX(msg[d],"!") = 0 THEN 40 ELSE INDEX(msg[d],"!"))
    i          = MINIMUM(i,j)
    msg[d + 1] = SUBSTRING(msg[d],i + 1)
    msg[d]     = SUBSTRING(msg[d],1,i
               - (IF SUBSTRING(msg[d],i,1) = "," THEN 0 ELSE 1))
    d          = d + 1.
END.

PAUSE 0.
DO i = 0 TO d WITH FRAME dbox-bot:
  DOWN.
  DISPLAY (IF i = 0 THEN "" ELSE msg[i]) @ pergunta.
END.

PAUSE 0.
VIEW FRAME dbox-top.
DISPLAY new_lang[1] @ msg[1] new_lang[2] @ msg[2] WITH FRAME dbox-top.
IF NOT resposta THEN NEXT-PROMPT msg[2] WITH FRAME dbox-top.
DO ON ERROR UNDO,LEAVE ON ENDKEY UNDO, LEAVE:
  CHOOSE FIELD msg[1 FOR 2] COLOR normal  AUTO-return WITH FRAME dbox-top.
END.
resposta = (FRAME-INDEX = 1 AND KEYFUNCTION(LASTKEY) <> "END-ERROR").
if keyfunction(lastkey) = "END-ERROR"
then resposta = ?.
HIDE FRAME dbox-bot NO-PAUSE.
HIDE FRAME dbox-top NO-PAUSE.
RETURN.
