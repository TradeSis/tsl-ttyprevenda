/* #102022 helio lebes bag */
/* #092022 helio bau */
/* medico na tela 042022 - helio */
{admcab.i}
/*
def var vtipo as char format "x(35)" extent 12
    initial[" 1. Pre Venda",
            " 2. Consultas",
              3 Consulta xtrato
              4 consulta est/for
              5 consulta vendas
            " 6. Pedidos",
            " 7. Atualiza",
            " 8. Analise de planos por vendedor",
            " 9. Intencao de compra", 
            " 10. Solicita Cartao Lebes",
            " 11. Porta-relatorios", 
            " 12. Sair"].


def var tipo-pedido as char format "x(15)" extent 1
    initial[" Automatico"].

def var tipo-atualiza as char format "x(30)" extent 4
    initial["Atualiza Promocao/Plano",
            "Atualiza Produto",
            "Atualiza Promocoes/Modulo",
            "Atualiza Promocoes Novas"].
*/
def var menp1   as char format "x(20)" extent 5 
        init  ["                    ",
               "     ASSISTENTE ",
               "         DE   ",
               "       VENDAS",
               ""].
def var prop1   as char init "wf-pre.p".

def var menp2   as char format "x(20)" extent 5 
        init  ["                    ",
               "      HUB ",
               "    SEGUROS ",
               "      ",
               ""].
def var prop2   as char init "seg/telahubsegini.p".
def var menp3   as char format "x(20)" extent 5   
        init  ["             ",
               "   ATUALIZA  ",
               "            ",
               "            ",
               ""].
def var prop3   as char init "menuatualiza.p".

def var menp4   as char format "x(20)" extent 5   
        init  ["      ",
               "   CHAMA ",
               "   DOUTOR ",
               "   ",
               ""].
def var prop4   as char init "medtelaini.p".
def var menp5   as char format "x(20)" extent 5   
        init  ["             ",
               "      CONSULTA  ",
               "      ESTOQUE ",
               "            ",
               ""].
               
def var prop5   as char init "pesco.p".
def var menp6   as char format "x(20)" extent 5   
        init  ["             ",
               "     BAU    ",
               "   JEQUITI",
               ""].
def var prop6   as char init "bauini.p".

def var menp7   as char format "x(20)" extent 5   
        init  ["             ",
               "   REVERSA  ",
               "     ",
               "            ",
               ""].
def var prop7   as char init "lojtreversa.p".

def var menp8   as char format "x(20)" extent 5   
        init  ["             ",
               "   LEBES  ",
               "    BAG ",
               "            ",
               ""].
def var prop8   as char init "bagini.p".

def var menp9  as char format "x(20)" extent 5   
        init  ["             ",
               "     PORTA  ",
               "   RELATORIOS ",
               ""].
def var prop9  as char init "edit-arq.p".

def var menp10  as char format "x(20)" extent 5   
        init  ["             ",
               "     CAD ",
               "   FUNCIONARIO",
               ""].
def var prop10  as char init "func.p".    
 
def var menp11   as char format "x(20)" extent 5 init  
              [""].
def var menp12   as char format "x(20)" extent 5 init  
              [""].
              
              
              


form menp1[1] skip menp1[2] skip menp1[3] skip menp1[4] skip menp1[5]
     with frame p1  row 3  no-labels 1 column
    no-box.
form  menp1[1] skip menp1[2] skip menp1[3] skip menp1[4] skip menp1[5]
    with frame c1  row 3  no-labels 1 column
    no-box
    color messages.

form menp2[1] skip menp2[2] skip menp2[3] skip menp2[4] skip menp2[5]
     with frame p2  row 3  no-labels 1 column col 21
    no-box.
form  menp2[1] skip menp2[2] skip menp2[3] skip menp2[4] skip menp2[5]
    with frame c2  row 3  no-labels 1 column col 21
    no-box
    color messages.

form menp3[1] skip menp3[2] skip menp3[3] skip menp3[4] skip menp3[5]
     with frame p3  row 3  no-labels 1 column col 41
    no-box.
form  menp3[1] skip menp3[2] skip menp3[3] skip menp3[4] skip menp3[5]
    with frame c3  row 3  no-labels 1 column col 41
    no-box
    color messages.
    
form menp4[1] skip menp4[2] skip menp4[3] skip menp4[4] skip menp4[5]
     with frame p4  row 3  no-labels 1 column col 61
    no-box.
form  menp4[1] skip menp4[2] skip menp4[3] skip menp4[4] skip menp4[5]
    with frame c4  row 3  no-labels 1 column col 61
    no-box
    color messages.

form menp5[1] skip menp5[2] skip menp5[3] skip menp5[4] skip menp5[5]
     with frame p5  row 9  no-labels 1 column
    no-box.
form  menp5[1] skip menp5[2] skip menp5[3] skip menp5[4] skip menp5[5]
    with frame c5  row 9  no-labels 1 column
    no-box
    color messages.

form menp6[1] skip menp6[2] skip menp6[3] skip menp6[4] skip menp6[5]
     with frame p6  row 9  no-labels 1 column col 21
    no-box.
form  menp6[1] skip menp6[2] skip menp6[3] skip menp6[4] skip menp6[5]
    with frame c6  row 9  no-labels 1 column col 21
    no-box
    color messages.

form menp7[1] skip menp7[2] skip menp7[3] skip menp7[4] skip menp7[5]
     with frame p7  row 9  no-labels 1 column col 41
    no-box.
form  menp7[1] skip menp7[2] skip menp7[3] skip menp7[4] skip menp7[5]
    with frame c7  row 9  no-labels 1 column col 41
    no-box
    color messages.
    
form menp8[1] skip menp8[2] skip menp8[3] skip menp8[4] skip menp8[5]
     with frame p8  row 9  no-labels 1 column col 61
    no-box.
form  menp8[1] skip menp8[2] skip menp8[3] skip menp8[4] skip menp8[5]
    with frame c8  row 9  no-labels 1 column col 61
    no-box
    color messages.
 

    
form menp9[1] skip menp9[2] skip menp9[3] skip menp9[4] skip menp9[5]
     with frame p9  row 15  no-labels 1 column
    no-box.
form  menp9[1] skip menp9[2] skip menp9[3] skip menp9[4] skip menp9[5]
    with frame c9  row 15  no-labels 1 column
    no-box
    color messages.

form menp10[1] skip menp10[2] skip menp10[3] skip menp10[4] skip menp10[5]
     with frame p10  row 15  no-labels 1 column col 21
    no-box.
form  menp10[1] skip menp10[2] skip menp10[3] skip menp10[4] skip menp10[5]
    with frame c10  row 15  no-labels 1 column col 21
    no-box
    color messages.

form menp11[1] skip menp11[2] skip menp11[3] skip menp11[4] skip menp11[5]
     with frame p11  row 15  no-labels 1 column col 41
    no-box.
form  menp11[1] skip menp11[2] skip menp11[3] skip menp11[4] skip menp11[5]
    with frame c11  row 15  no-labels 1 column col 41
    no-box
    color messages.
    
form menp12[1] skip menp12[2] skip menp12[3] skip menp12[4] skip menp12[5]
     with frame p12  row 15  no-labels 1 column col 61
    no-box.
form  menp12[1] skip menp12[2] skip menp12[3] skip menp12[4] skip menp12[5]
    with frame c12  row 15  no-labels 1 column col 61
    no-box
    color messages.
 
 
    

def var vpos as int.
vpos = 1.

disp menp1 with frame c1.
disp menp2 with frame p2.
disp menp3 with frame p3.
disp menp4 with frame p4.
disp menp5 with frame p5.
disp menp6 with frame p6.
disp menp7 with frame p7.
disp menp8 with frame p8.
disp menp9 with frame p9.
disp menp10 with frame p10.
disp menp11 with frame p11.
disp menp12 with frame p12.


repeat:
    hide message no-pause.
       readkey.
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame c1 no-pause.
        hide  frame c2 no-pause.
        hide  frame c3 no-pause.
        hide  frame c4 no-pause.
        hide  frame c5 no-pause.
        hide  frame c6 no-pause.
        hide  frame c7 no-pause.
        hide  frame c8 no-pause.
        hide  frame c9 no-pause.
        hide  frame c10 no-pause.
        hide  frame c11 no-pause.
        hide  frame c11 no-pause.
        
        hide  frame p1 no-pause.
        hide  frame p2 no-pause.
        hide  frame p3 no-pause.
        hide  frame p4 no-pause.
        hide  frame p5 no-pause.
        hide  frame p6 no-pause.
        hide  frame p7 no-pause.
        hide  frame p8 no-pause.
        hide  frame p9 no-pause.
        hide  frame p10 no-pause.
        hide  frame p11 no-pause.
        hide  frame p12 no-pause.
        
        leave.

    end.    
    pause 0.
    if keyfunction(lastkey) = "return"
    then do:
        hide frame c1 no-pause.
        hide  frame c2 no-pause.
        hide  frame c3 no-pause.
        hide  frame c4 no-pause.
        hide  frame c5 no-pause.
        hide  frame c6 no-pause.
        hide  frame c7 no-pause.
        hide  frame c8 no-pause.
        hide  frame c9 no-pause.
        hide  frame c10 no-pause.
        hide  frame c11 no-pause.
        hide  frame c11 no-pause.
        
        hide  frame p1 no-pause.
        hide  frame p2 no-pause.
        hide  frame p3 no-pause.
        hide  frame p4 no-pause.
        hide  frame p5 no-pause.
        hide  frame p6 no-pause.
        hide  frame p7 no-pause.
        hide  frame p8 no-pause.
        hide  frame p9 no-pause.
        hide  frame p10 no-pause.
        hide  frame p11 no-pause.
        hide  frame p12 no-pause.

        if vpos = 1
        then do:
            run value(prop1).
        end.

        if vpos = 2
        then do:
            run value(prop2).
        end.
        
        if vpos = 3
        then do:
            run value(prop3).
        end.
        if vpos = 4
        then do:
            run value(prop4).
        end.
        if vpos = 5
        then do:
            run value(prop5).
        end.
        if vpos = 6
        then do:
            run value(prop6).
        end.
        if vpos = 7
        then do:
            run value(prop7).
        end.
        if vpos = 8
        then do:
            run value(prop8).
        end.
        if vpos = 9
        then do:
            run value(prop9).
        end.
        if vpos = 10        then do:
            run value(prop10).
        end.
        
        
        
        disp menp1 with frame p1.
        disp menp2 with frame p2.
        disp menp3 with frame p3.
        disp menp4 with frame p4.
        disp menp5 with frame p5.
        disp menp6 with frame p6.
        disp menp7 with frame p7.
        disp menp8 with frame p8.
        disp menp9 with frame p9.
        disp menp10 with frame p10.
        disp menp11 with frame p11.
        disp menp12 with frame p12.
    end.
    
    if vpos = 1
    then do:
        hide frame c1 no-pause.
        disp    menp1 
        with frame p1.
    end.
    if vpos = 2
    then do:
        hide frame c2 no-pause.
        disp    menp2 
        with frame p2.
    end.
    if vpos = 3
    then do:
        hide frame c3 no-pause.
        disp    menp3 
        with frame p3.
    end.
    if vpos = 4
    then do:
        hide frame c4 no-pause.
        disp    menp4 
        with frame p4.
    end.
    
    if vpos = 5
    then do:
        hide frame c5 no-pause.
        disp    menp5 
        with frame p5.
    end.
    if vpos = 6
    then do:
        hide frame c6 no-pause.
        disp    menp6 
        with frame p6.
    end.
    if vpos = 7
    then do:
        hide frame c7 no-pause.
        disp    menp7 
        with frame p7.
    end.
    if vpos = 8
    then do:
        hide frame c8 no-pause.
        disp    menp8 
        with frame p8.
    end.
    
    if vpos = 9
    then do:
        hide frame c9 no-pause.
        disp    menp9 
        with frame p9.
    end.
    if vpos = 10
    then do:
        hide frame c10 no-pause.
        disp    menp10 
        with frame p10.
    end.
    if vpos = 11
    then do:
        hide frame c11 no-pause.
        disp    menp11 
        with frame p11.
    end.
    if vpos = 12
    then do:
        hide frame c12 no-pause.
        disp    menp12 
        with frame p12.
    end.
    
    
    if keyfunction(lastkey) = "cursor-right"
    then do:
        vpos = vpos + 1.
        if vpos > 12
        then vpos = vpos - 1.
    end.     
    if keyfunction(lastkey) = "cursor-left"
    then do:
        vpos = vpos - 1.
        if vpos <= 0 then vpos = vpos + 1.
    end.     
    if keyfunction(lastkey) = "cursor-down"
    then do:
        vpos = vpos + 4.
        if vpos < 0
        then vpos = vpos - 4.
        if vpos > 12
        then vpos = vpos - 4.
    end.    
    if keyfunction(lastkey) = "cursor-up"
    then do:
        vpos = vpos - 4.
        if vpos <= 0
        then vpos = vpos + 4.
        if vpos > 12
        then vpos = vpos + 4.
    end.    
    
    if vpos = 1 
    then do: 
        hide frame p1 no-pause.
        disp    menp1 
        with frame c1.
    end.
    if vpos = 2 
    then do: 
        hide frame p2 no-pause.
        disp    menp2 
        with frame c2.
    end.
    if vpos = 3 
    then do: 
        hide frame p3 no-pause.
        disp    menp3 
        with frame c3.
    end.
    if vpos = 4 
    then do: 
        hide frame p4 no-pause.
        disp    menp4 
        with frame c4.
    end.
    
    if vpos = 5
    then do: 
        hide frame p5 no-pause.
        disp    menp5 
        with frame c5.
    end.
    if vpos = 6 
    then do: 
        hide frame p6 no-pause.
        disp    menp6 
        with frame c6.
    end.
    if vpos = 7 
    then do: 
        hide frame p7 no-pause.
        disp    menp7 
        with frame c7.
    end.
    if vpos = 8 
    then do: 
        hide frame p8 no-pause.
        disp    menp8 
        with frame c8.
    end.
    if vpos = 9
    then do: 
        hide frame p9 no-pause.
        disp    menp9 
        with frame c9.
    end.
    if vpos = 10 
    then do: 
        hide frame p10 no-pause.
        disp    menp10 
        with frame c10.
    end.
    if vpos = 11 
    then do: 
        hide frame p11 no-pause.
        disp    menp11 
        with frame c11.
    end.
    if vpos = 12 
    then do: 
        hide frame p12 no-pause.
        disp    menp12 
        with frame c12.
    end.
end.    

