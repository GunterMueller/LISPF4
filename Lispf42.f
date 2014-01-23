C******FLOSOR      (AUX ROUTINES FOR INTERPRETER)
C***********************************************************************
C*                                                                     *
C*                           LISP F4 (FLOATING)                        *
C*                           -------                                   *
C*                                                                     *
C*       THE SYSTEM WAS WRITTEN BY    UPDATED BY                       *
C*       DR. MATS NORDSTROM           HANS ERIKSSON AND                *
C*                                    KRISTINA JOHANSSON               *
C*                                    DR. TORE RISCH                   *
C*       READER, PRINTER, ARRAYS, AND FLONUMS                          *
C*       WERE ADDED BY                MATS CARLSSON                    *
C*       THE STACK-VARIANT OF THE                                      *
C*       INTERPRETER WAS WRITTEN BY   JAAN KOORT                       *
C*                                                                     *
C*       UPMAIL                                                        *
C*       STUREGATAN 2A                                                 *
C*       S-752 23  UPPSALA                                             *
C*       SWEDEN                                                        *
C*                                                                     *
C*        THE WORK WAS SUPPORTED BY THE SWEDISH BOARD                  *
C*        FOR TECHNICAL DEVELOPMENT (STU) NO 76-4253.                  *
C*                                                                     *
C***********************************************************************
C*IBM SUPPLIED MACHINE CODE*      EXTERNAL BRSERV
      INTEGER ROLLIN
      DATA ISTART /0/
C-- SET UP INTERRUPT HANDLER
C*IBM SUPPLIED MACHINE CODE*      CALL BRSET(BRSERV)
      CALL BRSET
      CALL INIT1
      IF(ISTART.NE.0)GOTO 10
      CALL INIT2
      ISTART=1
      CALL LISPF4(1)
      CALL LSPEX
      STOP
C-- IN CASE OF INTERRUPT AND RESTART THE VARIABLE ISTART
C-- TELLS IF WE HAVE DONE THE INIT, THEN WE CAN CALL THE INTERPRETER
C-- DIRECTLY
C-- ON COMPUTERS WHERE YOU SAVE CORE IMAGES (E.G. DEC20) YOU CAN
C-- START THE LISPF4 SYSTEM, READ ALL LISPCODE YOU WANT AND THEN
C-- EXIT AND SAVE THE CORE IMAGE. THIS WAY YOU DONT HAVE TO USE ROLLFILES
C-- 
10    OPEN (10,FILE='LISPF4.IMG',STATUS='OLD',FORM='UNFORMATTED')
      IXCC = ROLLIN(10)
      CLOSE(10)
      CALL LISPF4(1)
      CALL LSPEX
      STOP
      END
C
      SUBROUTINE BRSERV
      INCLUDE 'F4COM.FOR'
C--  INTERRUPT HANDLER
      ERRTYP=26
      IBREAK=.TRUE.
      RETURN
      END
      SUBROUTINE APUSH(I)
      INCLUDE 'F4COM.FOR'
      JP=JP-1
      IF(IP .GE. JP) GO TO 2
      STACK(JP)=I
      RETURN
2     STACK(IP)=16
      JP=JP+1
      RETURN
      END
      SUBROUTINE APUSH2(I,J)
      INCLUDE 'F4COM.FOR'
      JP=JP-2
      IF (IP .GE. JP) GO TO 2
      STACK(JP+1)=I
      STACK(JP)=J
      RETURN
2     STACK(IP)=16
      JP=JP+2
      RETURN
      END
      SUBROUTINE APOP(I)
      INCLUDE 'F4COM.FOR'
      IF (JP .GT. NSTACK) GO TO 2
      I=STACK(JP)
      JP=JP+1
      RETURN
2     STACK(IP)=17
      JP=IP+1
      RETURN
      END
      SUBROUTINE APOP2(I,J)
      INCLUDE 'F4COM.FOR'
      IF (JP .GT. NSTACK) GO TO 2
      I=STACK(JP)
      J=STACK(JP+1)
      JP=JP+2
      RETURN
2     STACK(IP)=17
      JP=IP+1
      RETURN
      END
      SUBROUTINE APUSH3(I,J,K)
        INCLUDE 'F4COM.FOR'
      JP=JP-3
      IF (IP .GE. JP) GO TO 2
      STACK(JP+2)=I
      STACK(JP+1)=J
      STACK(JP)=K
      RETURN
2     STACK(IP)=16
      JP=JP+3
      RETURN
      END
      SUBROUTINE APOP3(I,J,K)
        INCLUDE 'F4COM.FOR'
      IF (JP .GT. NSTACK) GO TO 2
      I=STACK(JP)
      J=STACK(JP+1)
      K=STACK(JP+2)
      JP=JP+3
      RETURN
2     STACK(IP)=17
      JP=IP+1
      RETURN
      END
      SUBROUTINE FPUSH(I)
        INCLUDE 'F4COM.FOR'
      IP=IP+1
      IF (IP .GE. JP) GO TO 2
1     STACK(IP)=I
      RETURN
2     IP=IP-1
      STACK(IP)=16
      RETURN
      END
      SUBROUTINE FPOP(I)
        INCLUDE 'F4COM.FOR'
      I=STACK(IP)
      IP=IP-1
      RETURN
      END
      INTEGER FUNCTION CONS(I1,I2)
        INCLUDE 'F4COM.FOR'
      INTEGER GARB0
      IF (NFREEP .EQ. NIL) GO TO 3
      ICONS = NFREEP
      CONS = ICONS
      NFREEP=CDR(NFREEP)
C*SETC*      CALL SETCAR(ICONS,I1)
       CAR(ICONS)=I1 
C*SETC*      CALL SETCDR(ICONS,I2)
       CDR(ICONS)=I2 
      RETURN
3     CONS=GARB0(I1,I2)
      RETURN
      END
      INTEGER FUNCTION GARB0(I1,I2)
      INTEGER GARB
      INCLUDE 'F4COM.FOR'
C                                      PERFORM A FREE CELL GARB
3     I1CONS=I1
      I2CONS=I2
      I=GARB(0)
      ICONS=NFREEP
      GARB0 = ICONS
      NFREEP=CDR(NFREEP)
C*SETC*      CALL SETCAR(ICONS,I1CONS)
       CAR(ICONS)=I1CONS 
C*SETC*      CALL SETCDR(ICONS,I2CONS)
       CDR(ICONS)=I2CONS 
      IF (I .GT. ISPLFT) RETURN
      ISPLFT=ISPLFT/2
      IBREAK=.TRUE.
      ERRTYP=34
      RETURN
      END
      INTEGER FUNCTION SUBPR(IX,IY,IS)
        INCLUDE 'F4COM.FOR'
      INTEGER CONS,EQUAL
      INTEGER RES,S
      LOGICAL NLISTP
      EQUIVALENCE (RES,TEMP1),(S,TEMP2)
      NLISTP(IDUMMY) = IDUMMY.LE.NATOM .OR. IDUMMY.GT.NFREET
      S=IS
      CALL FPUSH(1)
C-- MEMB TEST OF S IN IX
5     J=IX
      K=IY
6     IF(NLISTP(J))GOTO 7
      IF(NLISTP(K))K=NIL
      IF(EQUAL(CAR(J),S).EQ.T)GOTO 8
      J=CDR(J)
      K=CDR(K)
      GOTO 6
7     IF(J.EQ.NIL.OR.J.NE.S)GOTO 10
C--   (SUBPAIR '(X Y . Z) '(A B C D E) '(X Y Z))=
C--     (A B C D E)
      RES=K
      GOTO 20
8     RES=CAR(K)
      GOTO 20
10    IF(S.GT.NATOM .AND. S.LE.NFREET) GOTO 30
16    RES=S
20    I=STACK(IP)
      IF (I.GT.3) GOTO 90
25    IP=IP-1
      GOTO (50, 35, 40),I
30    ICDR=CDR(S)
      CALL APUSH(ICDR)
      CALL FPUSH(2)
      S=CAR(S)
      GOTO 5
35    S=STACK(JP)
      STACK(JP)=RES
      CALL FPUSH(3)
      GOTO 5
40    CALL APOP(S)
      RES=CONS(S,RES)
      GOTO 20
50    SUBPR=RES
      RETURN
C             PDL OVERFLOW. LEAVE OFLO ADDRESS (16) IN F-STACK
90    RETURN
      END
      INTEGER FUNCTION EQUAL(II,JJ)
        INCLUDE 'F4COM.FOR'
      INTEGER COMPPN
      JPE=JP
      I=II
      J=JJ
10    IF (I.EQ.J) GOTO 50
      IF (I.LE.NATOM) GOTO 80
      IF (I.GT.NFREET) GOTO 70
      IF (J.LE.NATOM .OR. J.GT.NFREET) GOTO 60
C             I NOT EQ J. I AND J ARE LISTS
15    CALL APUSH2(I,J)
      I=CAR(I)
      J=CAR(J)
      GOTO 10
20    CALL APOP2(J,I)
      I=CDR(I)
      J=CDR(J)
      GOTO 10
50    IF (JP.LT.JPE) GOTO 20
51    EQUAL=T
      RETURN
60    JP=JPE
      EQUAL=NIL
      RETURN
C               I = NUMBER
70    IF (J.LE.NFREET) GOTO 60
      IF (GTREAL(I,IN) .NE. GTREAL(J,JN)) GOTO 60
      IF (IN.NE.JN) GOTO 60
      GOTO 50
C                                      I = LITERAL/STRING
80    IF (0.EQ.COMPPN(I,J)) GOTO 50
      GOTO 60
      END
      INTEGER FUNCTION GET(J,I)
        INCLUDE 'F4COM.FOR'
      IF (J.GT.NFREET) GOTO 40
      K = CDR(J)
8     IF (K.LE.NATOM .OR. K.GT.NFREET) GOTO 40
      IF (CAR(K).EQ.I) GOTO 20
12    K=CDR(K)
      K=CDR(K)
      GOTO 8
20    K=CDR(K)
      GET=CAR(K)
      RETURN
40    GET=NIL
      RETURN
      END
      INTEGER FUNCTION GETPN(X,MAIN,JB,IPL)
C-----
C     DECODES THE LITATOM/STRING/SUBSTRING X
C     MAIN   <-- POINTER TO MAIN STRING, IF SUBSTRING
C     JB     <-- BYTE OFFSET TO PRINTNAME
C     IPL    <-- BYTE LENGTH OF PRINTNAME
C     GETPN <-- -1 = X INVALID, 0 = LITATOM, 1 = STRING/SUBSTRING
C-----
        INCLUDE 'F4COM.FOR'
      INTEGER X,GETNUM
      IF (X.GT.NATOM) GOTO 9010
      JB = PNP(X)
      IPL = PNP(X+1) -JB
      MAIN = X
      IF (CAR(X).EQ.STRING) GOTO 9030
      IF (CAR(X).NE.SUBSTR) GOTO 9020
C                                      TAKE CARE OF THE SUBSTR CASE
      L = CDR(X)
      IF (L.GT.NFREET) GOTO 9010
      MAIN = CAR(L)
      IF (MAIN.GT.NATOM) GOTO 9010
      IF (CAR(MAIN).NE.STRING) GOTO 9010
      L = CDR(L)
      IF (L.GT.NFREET) GOTO 9010
      IF (CAR(L).LE.NFREET .OR. CDR(L).LE.NFREET) GOTO 9010
C                                      GET BYTE ADDR
      II = CAR(L)
      JB = PNP(MAIN) +GETNUM(II) -1
C                                      GET BYTE LENGTH
      II = CDR(L)
      IPL = GETNUM(II)
      GOTO 9030
C                                      EXITS.
9010  GETPN = -1
      RETURN
9020  GETPN = 0
      RETURN
9030  GETPN = 1
      RETURN
      END
      INTEGER FUNCTION COMPPN(X,Y)
C-----
C     COMPARES THE PRINTNAMES OF ITS ARGUMENTS
C     COMPPN <-- -2 IF X ILLEGAL;  <-- 2 IF Y IS ILLEGAL;
C            <-- -1 IF X < Y;      <-- 1 IF X > Y;
C            <--  0 IF X = Y;
C-----
        INCLUDE 'F4COM.FOR'
      INTEGER GETPN,X,Y
      COMPPN = -2
      IF (0.GT.GETPN(X,MAIN,JB,IPL)) RETURN
      COMPPN = 2
      IF (0.GT.GETPN(Y,MAIN,JB2,IPL2)) RETURN
      COMPPN = 0
      MIN = IPL
      IF (IPL.GT.IPL2) MIN = IPL2
      IF (MIN.EQ.0) GOTO 20
C                                      COMPARE BYTE BY BYTE
      DO 10 I = 1,MIN
         CALL GETCH(PNAME,ICH,JB)
         CALL GETCH(PNAME,JCH,JB2)
         IF (ICH.LT.JCH) GOTO 30
         IF (ICH.GT.JCH) GOTO 40
         JB = JB +1
10       JB2 = JB2 +1
20    IF (IPL-IPL2) 30,50,40
30    COMPPN = -1
      GOTO 50
40    COMPPN = 1
50    RETURN
      END
      SUBROUTINE ARRUTL(IPTR,IACTN,IPART,IFIRST,ILEN)
C----
C
C + TAKES CARE OF THE SYSTEM'S ARRAY HANDLING.
C   ARRAYS ARE REPRESENTED AS FOLLOWS:
C
C             +--------------+
C             !              !
C PNAME:...(Z * * (POINTERS) Z (INTEGERS) Z (REALS)) (NEXT ATOM)...
C          !    !                         !          !
C          !    +-------------------------+          !
C PNP:(IPTR)                                  (IPTR+1)
C
C CAR(IPTR) = ARRAY                    (BYTE POINTERS)
C CDR(IPTR) = NIL                      (Z = 0 OR MORE SLACK BYTES)
C
C + PARAMETERS:
C
C   IPTR       LISP POINTER TO ARRAY (AS ABOVE)
C
C   IACTN  = 1 GET ARRAY ELEMENT
C          = 2 SET ARRAY ELEMENT
C          = 3 SET IFIRST AND ILEN TO ARRAY PART BOUNDS
C          = 4 MAKE AN ARRAY PART, INITTED TO IFIRST
C
C   IPART  = 1 POINTER PART IS REFERRED TO
C          = 2 INTEGER PART
C          = 3 REAL PART
C
C   IFIRST:    ARRAY PART RELATIVE INDEX (IACTN = 1,2) OR
C              PNAME RELATIVE INDEX      (IACTN = 3,4)
C
C   ILEN:      PNAME RELATIVE INDEX TO VALUE (IACTN = 1,2) OR
C              NO. OF ELEMENTS IN PART (IACTN = 3,4)
C
C + NUMERIC ELEMENT VALUES ARE TRANSMITTED VIA IPNAME/PNAME
C
C-----
        INCLUDE 'F4COM.FOR'
      INTEGER*2 JPNAME(1)
      INTEGER IPNAME(1),LWORD(3),LLEN(3)
      EQUIVALENCE (JPNAME(1),IPNAME(1),PNAME(1))
      EQUIVALENCE (LWORD1,LWORD(1)),(LWORD2,LWORD(2)),(LWORD3,LWORD(3))
      EQUIVALENCE (LLEN1,LLEN(1)),(LLEN2,LLEN(2)),(LLEN3,LLEN(3))
      MKJBP(IDUMMY,IDUMMZ) = ((JBP +IDUMMZ -2) /IDUMMZ +IDUMMY)
     *                        *IDUMMZ +1
C
      IF (IBREAK) GOTO 9000
C                                      CHECK PARAMETER IPTR
      IF (IPTR.LT.NIL .OR. IPTR.GT.NATOM) GOTO 8010
      IF (CAR(IPTR).NE.ARRAY) GOTO 8010
C                                      GET ARRAY BOUNDS
      LBYTE1 = PNP(IPTR)
      LBYTE1 = IABS(LBYTE1)
      LWORD1 = (LBYTE1-2)/JBYTES +4
      IF (IACTN.EQ.4 .AND. IPART.EQ.1) GOTO 4000
      LBYTE2 = JPNAME(LWORD1-2)
      LLEN1 = (LBYTE2-LBYTE1)/JBYTES -2
      IF (IPART.LT.2) GOTO 20
      LWORD2 = (LBYTE2-2)/IBYTES +2
      LBYTE3 = JPNAME(LWORD1-1)
      LLEN2 = (LBYTE3-LBYTE2)/IBYTES
      IF (IPART.LT.3) GOTO 20
      LWORD3 = (LBYTE3-2)/BYTES +2
      LLEN3 = PNP(IPTR+1)
      LLEN3 = (IABS(LLEN3) - LBYTE3)/BYTES
20    GOTO (1000,2000,3000,4000), IACTN
C
C GET ARRAY ELEMENT (CALLED BY ELT,ELTI,ELTR)
C
1000  IF (IFIRST.LE.0 .OR. IFIRST.GT.LLEN(IPART)) GOTO 8020
      ILEN = LWORD(IPART)+IFIRST -1
      GOTO 9000
C
C SET ARRAY ELEMENT (CALLED BY SETA,SETI,SETR)
C
2000  IF (IFIRST.LE.0 .OR. IFIRST.GT.LLEN(IPART)) GOTO 8020
      IND = LWORD(IPART) +IFIRST -1
      IF (IPART.EQ.1) JPNAME(IND) = JPNAME(ILEN)
      IF (IPART.EQ.2) IPNAME(IND) = IPNAME(ILEN)
      IF (IPART.EQ.3)  PNAME(IND) =  PNAME(ILEN)
      GOTO 9000
C
C GET ARRAY BOUNDS (CALLED BY ARRAYSIZE AND GARB (STEPS 1,6))
C
3000  IFIRST = LWORD(IPART)
      ILEN = LLEN(IPART)
      GOTO 9000
C
C MAKE AN ARRAY (CALLED BY ARRAY AND GARB (STEP 4))
C REQUIRES THAT WE HAVE ENSURED THAT THERE IS ENOUGH SPACE ALREADY
C IFIRST = 0 YIELDS DEFAULT VALUES IN THE NEW ARRAY
C
4000  JFIRST = IFIRST
      GOTO (4100,4200,4300), IPART
C PTR PART
4100  JBP = MKJBP(ILEN+2,JBYTES)
      IF (ILEN.EQ.0 .OR. LWORD1.EQ.JFIRST) GOTO 4410
      DO 4150 J = 1,ILEN
         IF (JFIRST.EQ.0) GOTO 4120
         JPNAME(LWORD1) = JPNAME(JFIRST)
         JFIRST = JFIRST+1
         GOTO 4150
4120     JPNAME(LWORD1) = NIL
4150     LWORD1 = LWORD1+1
      GOTO 4410
C INT PART
4200  JBP = MKJBP(ILEN,IBYTES)
      IF (ILEN.EQ.0 .OR. LWORD2.EQ.JFIRST) GOTO 4420
      DO 4250 J = 1,ILEN
         IF (JFIRST.EQ.0) GOTO 4220
         IPNAME(LWORD2) = IPNAME(JFIRST)
         JFIRST = JFIRST+1
         GOTO 4250
4220     IPNAME(LWORD2) = 0
4250     LWORD2 = LWORD2+1
      GOTO 4420
C REAL PART
4300  JBP = MKJBP(ILEN,BYTES)
      IF (ILEN.EQ.0 .OR. LWORD3.EQ.JFIRST) GOTO 4430
      DO 4350 J = 1,ILEN
         IF (JFIRST.EQ.0) GOTO 4320
         PNAME(LWORD3) = PNAME(JFIRST)
         JFIRST = JFIRST+1
         GOTO 4350
4320     PNAME(LWORD3) = 0.
4350     LWORD3 = LWORD3+1
      GOTO 4430
C                                      SET THE POINTERS
4410  LWORD1 = LWORD1-ILEN
      JPNAME(LWORD1-2) = JBP
4420  JPNAME(LWORD1-1) = JBP
4430  PNP(IPTR+1) = JBP
      GOTO 9000
C                                      EXITS
C ARG NOT ARRAY
8010  IBREAK = .TRUE.
      ERRTYP = 21
      GOTO 9000
C ARRAY INDEX OUT OF BOUNDS
8020  IBREAK = .TRUE.
      ERRTYP = 28
      ARG = ARG2
9000  RETURN
      END
      SUBROUTINE INIT1
        INCLUDE 'F4COM.FOR'
C             AFTER CALLING INIT1 YOU MAY CALL ROLLIN INSTEAD OF INIT2
C             THE FOLLOWING VARIABLES ARE MACHINE DEPENDENT AND ARE TO BE
C             SET BY THE IMPLEMENTOR OF LISPF4
      NATOM=3000
      NFREET=100000
      NSTACK=1500
      NHTAB=4000
      NPNAME=5000
      HILL=1500
      JBYTES = 4
      IBYTES = 4
      BYTES=4
      LUNIN=5
      LUNUT=6
      LUNSYS=4
      MAXLUN=99
      IOBUFF=160
      NBYTES = 256
      CHDIV=2**24   
      MAXBIG= 2147483647
C           =2**31-1
      MAXINT=MAXBIG
      IRESOL = 8
      IPOWER = 50
      FUZZ = 5.E-8
C THE NEAREST 10**N LOWER THAN MAXBIG
      RMAX=10**(IFIX(ALOG10(FLOAT(MAXBIG)))-1)
C
C             THE FOLLOWING VARIABLES BELONGS TO INIT1 BUT MAY NOT
C             BE CHANGED BY VARIOUS IMPLEMENTATIONS
      NIL=1
      NBMESS = 40
      MAXMES = 40
      NCHTYP = 26
      NAREA=82
C               NAREA = THE LENGTH OF COMMON /B/ FROM ARG TO DREG(7)
      NFREEB=NATOM+1
      LUNINS=LUNIN
      LUNUTS=LUNUT
      BIGNUM=NFREET+NATOM
      ISMALL = (MAXINT-BIGNUM-1)/2
      NUMADD = MAXINT-ISMALL
      DPNP=NPNAME-NATOM
      DPNAME=DPNP-NFREET
      BIGMAX = FLOAT(MAXBIG)
C                   NOW FOLLOW VARIABLE SETTINGS THAT
C                   ONLY HAVE TO BE DONE ONCE PER RUN.
C STACK
       STACK(1)=17
C PNP
      DO 10 I = 1,NATOM
10       PNP(I) = 1
      GARBS=0
      CGARBS=0
      AGARBS=0
      NGARBS = 0
      RETURN
      END
      SUBROUTINE INIT2
        INCLUDE 'F4COM.FOR'
C             ALL MACHINE INDEPENDENT INITIALIZATIONS ARE DONE HERE
C             INIT2 MAY BE REPLACED BY A CALL TO ROLLIN
C
      INTEGER ICH(26),ISYS(7),ARGS(10),ISYS2(22)
      EQUIVALENCE (SPACE,ICH(1)),(SUBR0,ISYS(1)),(ARG,ARGS(1))
      EQUIVALENCE (A000,ISYS2(1))
      NATOMP=0
      IP=1
      JP=NSTACK+1
        JBP=1
        NUMBP=NPNAME+1
        ABUP1=0
      LMARGR=1
      LMARG=1
      MARGR = 80
      MARG = 80
      LEVELL = 1000
      LEVELP = 1000
      MAXPAR = 3
      ITABWG = 8
      MIDDL=NSTACK/10
      UNUSED=-1001
C
C      BELOW IS CODE THAT OPENS SYSATOMS AT RUNTIME SO YOU DON'T NEED
C      TO ASSIGN IT.
C
      OPEN(UNIT=LUNSYS ,NAME='SYSATOMS',ERR=3,STATUS='OLD')
      GOTO 4
3     WRITE(LUNUTS,5)
5     FORMAT(1X,22HCANT'T OPEN 'SYSATOMS')
      STOP
C
C
C
C             READ SYSTEM CHARACTERS
 4    CALL RDA1(LUNSYS,ICH,1,NCHTYP,IEOF)
C
C
C
CDEBUG      WRITE(LUNUTS,29)(ICH(IIII),IIII=1,26)
CDEBUG29    FORMAT(' ICH=',26A1)
C             READ  ()<>"'..T+-0123456789%^E#
C             IF YOU GOT THE BCD-CODED VERSION, YOU MUST REPLACE THE
C             CHARACTERS FOR PROCENT, LEFT-BRACKET, RIGHT-BRACKET BY
C             SOMETHING ELSE
C
C             CLEAR HTAB
      DO 30 I=1,NHTAB
30    HTAB(I)=UNUSED
C
C             CLEAR CAR AND CDR AND MAKE FREE LISTS
      NFREEP=NIL
      DO 180  I=NFREEB,NFREET
C*SETC*      CALL SETCAR(I,NIL)
       CAR(I)=NIL 
C*SETC*      CALL SETCDR(I,NFREEP)
       CDR(I)=NFREEP 
180   NFREEP=I
C             INITIALIZE CHTAB
      DO 200 I=1,NBYTES
200   CHTAB(I)=10
C             PUT CHARACTER TYPES IN CHTAB
      DO 220 I = 1,NCHTYP
220      CALL SETCHT(ICH(I),I)
      DO 225 I=1,IOBUFF
      BUFF(I) = SPACE
      RDBUFF(I) = SPACE
      PRBUFF(I) = SPACE
225   ABUFF(I)=SPACE
      PRTPOS=1
      RDPOS=1000
      CHT=1
C
      NARGS=10
      NUMGEN = 0
      DO 250 I=1,7
250   DREG(I)=NIL
      IFLG1=NIL
      IFLG2=NIL
      DO 260 I=1,NARGS
260   ARGS(I)=NIL
C             USE LISP READ FUNCTION TO READ LISTS OF FUNCTION NAMES
C             FROM LUNSYS THUS CREATING ATOMS FOR THE SYS-FUNCTIONS
C
C             THE INTERVALS SUBR0 - FSUBR ARE EQUIVALENCE TO ISYS
C
C             SUBR0 = LAST FUNCTION WITH 0 ARGS
C             SUBR11= LAST FUNCTION WITH 1 NUMERICAL ARG
C             SUBR1 = LAST FUNCTION WITH 1 ARG (MAY NOT BE NUM ARG)
C             SUBR2 = LAST FUNCTION WITH 2 ARGS
C             SUBR3 = LAST FUNCTION WITH 3 ARGS
C             SUBR  = LAST FUNCTION WITH N ARGS
C             FSUBR= LAST FSUBR
      LUNIN=LUNSYS
      DO 270 I=1,7
      ICAR = IREAD(0)
      ISYS(I)=NATOMP
CDEBUG      WRITE(LUNUTS,500)NATOMP
CDEBUG500   FORMAT(' NATOMP =',I4)
CDEBUG      WRITE(LUNUTS,501)(PNAME(IIII),IIII=1,20)
CDEBUG501   FORMAT(4(' PNAME ',5A5,/))
270   CONTINUE
C             DEFINE SOME ATOM-INDEX SEPARATELY
      DO 275 I = 1,22
275      ISYS2(I) = IREAD(0)
      LUNIN=LUNINS
C                                      SET CAR OF ATOMS
      DO 280 I = NIL,NATOMP
C*SETC*280      CALL SETCAR(I, UNBOUN)
280      CAR(I)= UNBOUN 
C*SETC*      CALL SETCAR(NIL,NIL)
       CAR(NIL)=NIL 
C*SETC*      CALL SETCAR(T,T)
       CAR(T)=T 
C             INITIALIZE MESS (HAVE MESS TO READ MESSAGES FROM LUNSYS)
      CALL MESS(0)
      CLOSE(LUNSYS)
      RETURN
      END
      INTEGER FUNCTION ROLLIN(LUN)
        INCLUDE 'F4COM.FOR'
      INTEGER CINF(15),AREA(1),ACOM(8),BCOM(26)
      INTEGER JPNAME(6006)
      EQUIVALENCE
     * (NATOPO,CINF(9)),
     * (NFREPO,CINF(10)),
     * (JBPO  ,CINF(11)),
     * (NUMBPO,CINF(12)),
     * (NFRETO,CINF(13)),
     * (NUMADO,CINF(14)),
     * (NPNAMO,CINF(15))
      EQUIVALENCE(ARG,AREA(1)),(NAREA,ACOM(1)),(SPACE,BCOM(1))
      EQUIVALENCE (JPNAME(1),PNAME(1))
      INREAL = BYTES/JBYTES
      CALL DMPIN(LUN,CINF,1,15)
C             CHECK IF ROLLIN POSSIBLE
      DO 1 I = 1,8
      IF(CINF(I) .NE. ACOM(I)) GOTO 90
1     CONTINUE
C               ATOM SPACE
      IF(NATOPO+1 .GE. NATOM) GOTO 90
C               PRINT NAMES AND FLOATING NUMBERS
      IF((JBPO-2)/BYTES+2+NPNAMO-NUMBPO .GE. NPNAME) GOTO 90
C               FREE STORAGE
      IF(NFRETO-NFREPO .GE. NFREET-NFREEB) GOTO 90
C               ROLLIN POSSIBLE, MOVE POINTERS AND READ.
      IDIFF1=NFREET-NFRETO
      IDIFF2=NUMADD-NUMADO
      NATOMP=NATOPO
      NFREEP=NFREPO+IDIFF1
      JBP=JBPO
      NUMBP=NUMBPO+NPNAME-NPNAMO
      CALL DMPIN(LUN,IMESS,1,NBMESS/IBYTES *MAXMES)
      CALL DMPIN(LUN,AREA,1,NAREA)
C                                      STACK IS USED PRIOR TO RESET.
      IP=1
      JP=NSTACK+1
      CALL DMPIN2(LUN,JPNAME,1,(JBP-2)/JBYTES+1)
      CALL DMPIN2(LUN,JPNAME, (NUMBP-1)*INREAL+1, NPNAME*INREAL)
      CALL  DMPIN2(LUN,PNP,1,NATOMP+1)
C*SETC*      CALL  DMPIN2(LUN,CARCDR,NIL,NATOMP)
      CALL  DMPIN2(LUN,CAR,NIL,NATOMP)
C*SETC*C
      CALL  DMPIN2(LUN,CDR,NIL,NATOMP)
C*SETC*      CALL  DMPIN2(LUN,CARCDR,NFREEP+1,NFREET)
      CALL  DMPIN2(LUN,CAR,NFREEP+1,NFREET)
C*SETC*C
      CALL  DMPIN2(LUN,CDR,NFREEP+1,NFREET)
      CALL DMPIN(LUN,BCOM,1,NCHTYP)
      CALL  DMPIN2(LUN,CHTAB,1,NBYTES)
C
C             CHECK IF WE NEED TO MOVE POINTERS
C
      IF (IDIFF1.GE.0) GOTO 22
C      CALL FTYPE('MOVING 1')
      CALL MOVE(IDIFF1,NFREEP-IDIFF1,BIGNUM-IDIFF1)
22    IF (IDIFF2.EQ.0) GOTO 24
C      CALL FTYPE('MOVING 2')
      CALL MOVE(IDIFF2,BIGNUM-IDIFF2,MAXINT)
24    IF (IDIFF1.LE.0) GOTO 30
C      CALL FTYPE('MOVING 3')
      CALL MOVE(IDIFF1,NFREEP-IDIFF1,BIGNUM-IDIFF1)
C
C     MAKE FREE LIST
C
30    MAX=NFREEP
      NFREEP=NIL
      DO 35 I=NFREEB,MAX
C*SETC*      CALL SETCAR(I,NIL)
       CAR(I)=NIL 
C*SETC*      CALL SETCDR(I,NFREEP)
       CDR(I)=NFREEP 
35    NFREEP=I
C
C             REHASH THE ATOMS
C
      CALL REHASH
C
C               CLEAR BUFFERS
      DO 60 I=1,IOBUFF
      ABUFF(I)=SPACE
      BUFF(I)=SPACE
      RDBUFF(I)=SPACE
      PRBUFF(I)=SPACE
60    CONTINUE
      PRTPOS=1
      RDPOS=1000
      CHT = 1
      ABUP1=0
      ROLLIN=LUN+NUMADD
      GOTO 91
90    ROLLIN=NIL
91    CALL REW(LUN)
      RETURN
      END
      SUBROUTINE ROLLOU(LUN)
        INCLUDE 'F4COM.FOR'
      INTEGER GARB,CINF(15),AREA(1),BCOM(26)
      INTEGER JPNAME(6006)
      EQUIVALENCE (NAREA,CINF(1)),(ARG,AREA(1)),(SPACE,BCOM(1))
      EQUIVALENCE (JPNAME(1),PNAME(1))
      INREAL = BYTES/JBYTES
C             CALL COMPACTING GBC
      I = GARB(1)
      CALL DMPOUT(LUN,CINF,1,15)
      CALL DMPOUT(LUN,IMESS,1,NBMESS/IBYTES *MAXMES)
      CALL DMPOUT(LUN,AREA,1,NAREA)
      CALL DMPOU2(LUN,JPNAME,1,(JBP-2)/JBYTES+1)
      CALL DMPOU2(LUN,JPNAME, (NUMBP-1)*INREAL+1, NPNAME*INREAL)
      CALL DMPOU2(LUN,PNP,1,NATOMP+1)
C*SETC*      CALL DMPOU2(LUN,CARCDR,NIL,NATOMP)
      CALL DMPOU2(LUN,CAR,NIL,NATOMP)
C*SETC*C
      CALL DMPOU2(LUN,CDR,NIL,NATOMP)
C*SETC*      CALL DMPOU2(LUN,CARCDR,NFREEP+1,NFREET)
      CALL DMPOU2(LUN,CAR,NFREEP+1,NFREET)
C*SETC*C
      CALL DMPOU2(LUN,CDR,NFREEP+1,NFREET)
      CALL DMPOUT(LUN,BCOM,1,NCHTYP)
      CALL DMPOU2(LUN,CHTAB,1,NBYTES)
      CALL REW(LUN)
      RETURN
      END
      SUBROUTINE MOVE(DIFF,MIN,MAX)
        INCLUDE 'F4COM.FOR'
      INTEGER DIFF,ARGS(10)
      EQUIVALENCE (ARG,ARGS(1))
C
C             USED BY ROLLIN TO ADD DIFF TO POINTERS POINTING
C             IN (.GT.MIN , .LE.MAX)
      I1=NIL
      I2=NATOMP
      DO 20 J=1,2
      DO 10 I=I1,I2
C*SETC*      IF(CAR(I).GT.MIN.AND.CAR(I).LE.MAX) CALL SETCAR(I,CAR(I)+DIFF)
      IF(CAR(I).GT.MIN.AND.CAR(I).LE.MAX)  CAR(I)=CAR(I +DIFF)
C*SETC*      IF(CDR(I).GT.MIN.AND.CDR(I).LE.MAX) CALL SETCDR(I,CDR(I)+DIFF)
      IF(CDR(I).GT.MIN.AND.CDR(I).LE.MAX)  CDR(I)=CDR(I +DIFF)
10    CONTINUE
      I1=NFREEP
20    I2=NFREET
      DO 50 I=1,NARGS
      IF(ARGS(I) .GT. MIN.AND.ARGS(I).LE.MAX) ARGS(I)=ARGS(I)+DIFF
50    CONTINUE
      RETURN
      END
      SUBROUTINE PRIN1(S)
        INCLUDE 'F4COM.FOR'
C-----
C
C     THE GENERAL PRINT ROUTINE
C
C-----
      INTEGER S,X,Y,XX,RETC,RETU,GLCOUN,GLNKW,GLLEV,
     1        X2,GLLBEF,GET,CCOL
      LOGICAL LISTP,NLISTP
       LISTP(IDUMMY) = IDUMMY.GT.NATOM .AND. IDUMMY.LE.NFREET
      NLISTP(IDUMMY) = IDUMMY.LE.NATOM .OR.  IDUMMY.GT.NFREET
C
C--------------------------------------MAIN ENTRY
      X = S
      CALL APUSH2(IP,LMARG)
C                                      STACK OVERFLOW PREVENTION
      IF (STACK(IP).EQ.16) RETURN
      IDIV = 3
      IF (DREG(2).NE.NIL) IDIV = 5
      LEVELM = (JP-IP)/IDIV -1
      IF (LEVELP.LT.LEVELM) LEVELM = LEVELP
      JPOLD = JP
      GLLEV = 0
      CCOL = 2*MARG/3
      JPCOM = -10
      X2 = NIL
      RETU = 2
      GOTO 1000
C--------------------------------------RETURN
C--TERMINAL INTERRUPT (FROM UNKWOTE)
18    CALL TERPRI
C--FROM PRINT-S
20    JP = JPOLD
      CALL APOP2(LMARG,IP)
      RETURN
C
C--------------------------------------ENTRY LASTDEPTH(X)
500   LDEPTH = GLLEV
      RETU = 1
C--FROM UNKWOTE
510   IF (LDEPTH.EQ.LEVELM .OR. NLISTP(X)) GOTO 550
      LDEPTH = LDEPTH+1
C                                      X := LAST(X)
      DO 520 I = 1,LEVELL
         Y = CDR(X)
         IF (Y.EQ.NIL) GOTO 530
         X = Y
         IF (NLISTP(Y)) GOTO 510
520      CONTINUE
      GOTO 550
C                                      X := UNKWOTE(CAR(X))
530   X = CAR(X)
      GOTO 1000
C                                      RETURN(LDEPTH)
550   IRET = LDEPTH-GLLEV
      GOTO 5020
C
C--------------------------------------ENTRY UNKWOTE(X)
1000  IF(IBREAK)GOTO 18
      GLCOUN = 0
      IF (DREG(3).EQ.NIL) GOTO 1010
1005  IF (NLISTP(X)) GOTO 1010
      Y = CDR(X)
      IF (CAR(X).NE.QUOTE .OR. NLISTP(Y)) GOTO 1010
      IF (CDR(Y).NE.NIL) GOTO 1010
      GLCOUN = GLCOUN+1
      X = CAR(Y)
      GOTO 1005
1010  IF (RETU.EQ.2 .OR. RETU.EQ.4) GLNKW = GLCOUN
      GOTO (510,2000,1504,5105), RETU
C
C--------------------------------------ENTRY NCHARS(X)
1500  JPSAV = JP
      RETU = 3
C                                      COUNT THE QUOTES.
      GOTO 1000
C--FROM UNKWOTE
1504  IRET = IRET+GLCOUN
C                                      GONE PAST RIGHT MARGIN ?
      IF (IRET.GT.MARG) GOTO 1580
C                                      A LITATOM ?
      IF (X.GT.NATOM) GOTO 1520
      IF (CAR(X).EQ.ARRAY) GOTO 1530
      IRET = IRET+(PNP(X+1)-PNP(X))+1
      GOTO 1590
C                                      A NUMBER ?
1520  IF (X.GT.NFREET) GOTO 1530
C                                      DEEP ENOUGH ?
      IF (GLLEV+(JPSAV-JP)/2 .LT. LEVELM) GOTO 1550
1530  IRET = IRET+4
      GOTO 1590
C                                      GO DOWN CAR DIRECTION
1550  JP = JP-2
      STACK(JP+1) = 0
1555  STACK(JP) = X
      X = CAR(X)
      GOTO 1000
C                                      ... AND CDR DIRECTION
1560  X = STACK(JP)
      IF (X.LT.NIL) GOTO 1585
      X = CDR(X)
C                                      SIMULATE A GRAPHIC  ---  ?
      STACK(JP+1) = STACK(JP+1) + 1
      IF (STACK(JP+1).GE.LEVELL) X = NUMADD
      IF (LISTP(X)) GOTO 1555
      STACK(JP) = -1
      GOTO 1000
C                                      BACKUP
1580  JP = JPSAV-2
1585  JP = JP+2
1590  IF (JPSAV-JP) 1580,1591,1560
C                                      EXIT
1591  IF (JPCOM) 5032,5032,3001
C
C--------------------------------------ENTRY PRINT-S(X)
C
C--FROM UNKWOTE                        DEEP ENOUGH ?
2000  IF (GLLEV.GE.LEVELM .AND. LISTP(X)) X = -1
      IF (NLISTP(X)) GOTO 2030
C                                      PRINT-L(X,X2)
2010  IF (X2.GT.NUMADD) X2 = X2-1
      IF (DREG(2).NE.NIL) CALL APUSH2(LPRBRK,LLMARG)
      CALL APUSH3(LI,X2,X)
      IF (JP.EQ.JPCOM) DREG(2) = NIL
      GOTO 5000
C--FROM PRINT-L
2020  IF (JP.EQ.JPCOM) DREG(2) = T
      CALL APOP3 (X,X2,LI)
      IF (DREG(2).NE.NIL) CALL APOP2 (LLMARG,LPRBRK)
      GLLBEF = T
      IF (JP-IDIV.NE.JPCOM) GOTO 2040
      JPCOM = -10
      IF (LMARG.EQ.10) GOTO 2500
C--FROM TERPRI2
2025  LMARG = XX
      GOTO 2040
C                                      PRINAT(X)
2030  CALL PRINAT(X,GLNKW,JPOLD)
      GLLBEF = NIL
2040  IF (GLLEV) 20,20,5120
C
C--------------------------------------ENTRY TERPRI2
2500  DO 2510 I = 1,2
2510     CALL TERPRI
      IF (JPCOM) 2025,2025,3040
C
C--------------------------------------ENTRY LINEBREAK(X)
3000  IF (LPRBRK.EQ.-1) GOTO 3030
C                                      COMMENT NEXT ?
      IF (NLISTP(X)) GOTO 3010
      XX = CAR(X)
      IF (XX.GT.NATOM) GOTO 3010
      XX = GET(XX,FNCELL)
      IF (CDR(XX).NE.QUOTE) GOTO 3010
C                                      SWITCH TO COMMENT MODE
      JPCOM = JP-IDIV
      XX = LMARG
      LMARG = CCOL
      IRET = 20-MARG
C                                      CALL NCHARS(X)
      GOTO 1500
C--FROM NCHARS
3001  X = STACK(JP)
      X = CAR(X)
      IF (IRET.LE.MARG) GOTO 3025
      LMARG = 10
      GOTO 2500
C                                      NOT COMMENT
3010  IF (LI.LT.2 .OR. LPRBRK.NE.1) GOTO 3020
      IF (LISTP(X)) GOTO 3025
C                                      PROG--LABEL
      CALL TERPRI
      PRTPOS = LMARG-5
      GOTO 3040
C                                      NOT PROG.
3020  IF (.NOT.(LISTP(X) .OR. GLLBEF.NE.NIL)) GOTO 3030
3025  IF (PRTPOS.GE.LMARG) CALL TERPRI
      PRTPOS = LMARG
      GOTO 3040
C                                      (SPACES 1)
3030  PRTPOS = PRTPOS+1
C--FROM TERPRI2                        RETURN
3040  GOTO 5110
C
C--------------------------------------ENTRY PRINT-C
3500  IF (PRTPOS.GE.MARG+1) CALL TERPRI
      PRBUFF(PRTPOS) = IC
      PRTPOS = PRTPOS+1
      GOTO (5030,5210,5010), RETC
C
C--------------------------------------ENTRY PRINT-L
C
C THE VARIABLE LPRBRK CARRIES INFORMATION ABOUT WHEN TO PERFORM
C TERPRI AND WHEN NOT.  IT IS TESTED BY LINEBREAK.  IT CONTAINS
C THE FOLLOWING INFO:
C
C <0       MEANS THAT LINEBREAK WILL NOT PERFORM ANY TERPRI-ES.
C           THIS WILL BE THE CASE IF  E I T H E R
C           1) THE EXPRESSION ALMOST CERTAINLY WILL FIT ON LINE,  O R
C           2) NO PARENTHESISES WILL BE VISIBLE INSIDE THIS
C              EXPRESSION, DUE TO THE CURRENT PRINTLEVEL.
C >0  INFO ABOUT CAR(CURRENT EXPRESSION)
C    = 0    ATOM
C    = 1    THE ATOM PROG
C    = 2    A LIST
C
5000  LI = 0
      LLMARG = LMARG
      LPRBRK = -1
C                                      PRINT ZERO OR MORE '-S
      IC = IQCHR
      RETC = 3
C--FROM PRINT-C
5010  IF (GLNKW.EQ.0) GOTO 5015
         GLNKW = GLNKW-1
         GOTO 3500
5015  IC = LPAR
      RETC = 1
      IF (X2.NE.NIL) GOTO 3500
C                                      X2=NIL, CALL LASTDEPTH
      IF (DREG(2).NE.NIL) GOTO 500
      IRET = 0
      GOTO 5025
C--FROM LASTDEPTH
5020  IF (IRET.GT.MAXPAR) IC = ILBCHR
      IF (IRET.LE.MAXPAR) IRET = 0
5025  STACK(JP+1) = IRET+NUMADD
      GOTO 3500
C--FROM PRINT-C                        WE HAVE PRINTED ( OR <
5030  IF (DREG(2).EQ.NIL) GOTO 5050
C                                      TEST IF X WILL FIT ON LINE
      IF (GLLEV+1.GE.LEVELM) GOTO 5040
      IF (DREG(7).NE.NIL) GOTO 5035
C                                      CALL NCHARS(X)
      X = STACK(JP)
      IRET = PRTPOS
      GOTO 1500
C--FROM NCHARS
5032  IF (IRET.LE.MARG) GOTO 5040
5035  X = STACK(JP)
      X = CAR(X)
      LPRBRK = 0
      IF (X.EQ.PROG) LPRBRK = 1
      IF (LISTP(X)) LPRBRK = 2
5040  LMARG = PRTPOS+1
      IF (LMARG.GT.MARG-3) LMARG = MARG-3
5050  GLLEV = GLLEV+1
C                                      THE 'BIG' LOOP
5100  X = STACK(JP)
      X = CAR(X)
      RETU = 4
      GOTO 1000
C--FROM UNKWOTE
5105  IF (LI.GT.0) GOTO 3000
C--FROM LINEBREAK                      CALL PRINT-S
5110  X2 = STACK(JP)
      STACK(JP) = CDR(X2)
      X2 = NIL
      IF (STACK(JP).EQ.NIL) X2 = STACK(JP+1)
      GOTO 2000
C--FROM PRINT-S
5120  LI = LI+1
C                                      PERHAPS MOVE LMARG FURTHER RIGHT
      IF (LI.NE.1 .OR. (LPRBRK+2)/2.NE.1) GOTO 5130
      IF (PRTPOS.LT.(MARG + ITABWG*LMARG)/(ITABWG+1)) LMARG = 1+PRTPOS
C                                      TAKE NEXT ELEMENT OF LIST
5130  X = STACK(JP)
      IF (X.EQ.NIL) GOTO 5200
      IF (LISTP(X)) GOTO 5150
C                                      ATOM IS NEXT
      IF (PRTPOS+2.GE.MARG) CALL TERPRI
      PRBUFF(PRTPOS+1) = DOT
      PRTPOS = PRTPOS+3
      GOTO 5160
C                                      LIST IS NEXT
5150  IF (LI.LT.LEVELL) GOTO 5100
      X = -2
      PRTPOS = PRTPOS+1
C                                      CALL PRINAT
5160  CALL PRINAT(X,GLNKW,JPOLD)
C                                      PRINT ) OR >
5200  X2 = STACK(JP+1) - NUMADD
      IF (X2.LT.0 .OR. X2.GT.1) GOTO 5210
      IC = RPAR
      RETC = 2
      IF (X2.EQ.1) IC = IRBCHR
      GOTO 3500
C--FROM PRINT-C
5210  GLLEV = GLLEV-1
      LMARG = LLMARG
      GOTO 2020
C
      END
      SUBROUTINE PRINAT(X,NKW,JPOLD)
        INCLUDE 'F4COM.FOR'
C-----
C
C     PRINAT WILL PRINT A LISP ATOM OR:
C
C     X = -1  ==>  THE SYMBOL  ...
C       = -2  ==>              ---
C
C     NKW IS THE NUMBER OF '-S TO PRINT
C
C     JPOLD IS A SAVED STACK POINTER, IN CASE OF ERROR
C-----
      INTEGER OLDPOS,X,NKW,GETCHT,GETPN
C
      LOGICAL CLEAR
      CLEAR=PRTPOS.EQ.1
      OLDPOS = PRTPOS
C ***                                   DELETED STATEMENT(S). ***
      IPL = 0
      IF (NKW.EQ.0) GOTO 150
      DO 100 I = 1,NKW
         PRBUFF(PRTPOS) = IQCHR
100      PRTPOS = PRTPOS+1
150   IF (X.GE.NIL) GOTO 200
C                                      ... OR ---
      ISI = 3
      IPL = 3
      IC = DOT
      IF (X.EQ.-2) IC = IMINUS
      GOTO 300
200   IF (X.LE.NATOM) GOTO 295
C                                      --- NUMBER ---
      IF (X.GT.BIGNUM) CALL PRIINT(X-NUMADD)
      IF (X.LE.BIGNUM) CALL PRIFLO(GTREAL(X,IRET))
      GOTO 900
C                                      --- LITERAL ---
C                                      PICK UP ITS LENGTH
295   IF (CAR(X).NE.ARRAY) GOTO 296
      PRBUFF(PRTPOS) = NOCHAR
      PRTPOS = PRTPOS+1
      CALL PRIINT(X)
      GOTO 900
296   ISI = 1+GETPN(X,MAIN,JB,IPL)
      IF (ISI.EQ.0) GOTO 9100
      IF (ISI.EQ.2 .AND. DREG(5).EQ.NIL) ISI = 1
      IF (ISI.EQ.1) GOTO 300
      PRBUFF(PRTPOS) = STRCHR
      PRTPOS = PRTPOS+1
300   IF (IPL.EQ.0) GOTO 850
         IF (PRTPOS.GT.IOBUFF-3) GOTO 910
310      IF (ISI.GT.2) GOTO 700
C                                      GET CHAR
         CALL GETCH(PNAME,IC,JB)
         JB = JB+1
         IF (DREG(5).EQ.NIL) GOTO 700
C                                      GET TYPE
         JJ = GETCHT(IC)
C                                      % MAY BE NEEDED
         GOTO (400,500), ISI
400      IF (JJ.LE.8 .OR.  JJ.EQ.23) GOTO 600
         IF (JJ.EQ.9 .AND. X.EQ.DOTAT) GOTO 600
         GOTO 700
500      IF (JJ.NE.6 .AND. JJ.NE.23) GOTO 700
600      PRBUFF(PRTPOS) = ATEND
         PRTPOS = PRTPOS+1
700      PRBUFF(PRTPOS) = IC
         PRTPOS = PRTPOS+1
         IPL = IPL-1
         GOTO 300
C                                      ATOM NOW STORED. OFLO TEST.
850   IF (ISI.NE.2) GOTO 900
      PRBUFF(PRTPOS) = STRCHR
      PRTPOS = PRTPOS+1
900   IF (PRTPOS.LE.MARG+1) GOTO 1200
C                                      YES, IT HAS OVERFLOWED.
910   NEWPOS = PRTPOS
C                                      OUTPUT ANY OLD INFO
      IF (CLEAR) GOTO 915
      CLEAR=.TRUE.
      PRTPOS=OLDPOS
      CALL TERPRI
C               CLEAR RIGHT MARGIN BY MOVING TEXT LEFT
915   L=NEWPOS-OLDPOS
      PRTPOS=(MARG+1)-L
      IF (PRTPOS.GT.LMARG) PRTPOS=LMARG
      IF (PRTPOS.LT.1) PRTPOS=1
      DO 930 J=1,L
         IF (PRTPOS.LE.MARG) GOTO 920
         CALL TERPRI
         PRTPOS=1
920      IF (PRTPOS.EQ.OLDPOS) GOTO 925
         PRBUFF(PRTPOS)=PRBUFF(OLDPOS)
         PRBUFF(OLDPOS)=SPACE
925      PRTPOS=PRTPOS+1
930      OLDPOS=OLDPOS+1
      OLDPOS=PRTPOS-L
      IF (OLDPOS.LT.1) OLDPOS=1
C                                      PERHAPS JUMP BACK TO THE LOOP
950   IF (IPL.GT.0) GOTO 310
C                                      READY. RETURN.
1200  RETURN
C                                      ERROR: INVALID SUBSTRING
9100  X = NIL
      ERRTYP = 29
      IBREAK = .TRUE.
      GOTO 295
      END
      SUBROUTINE PRIFLO(R)
        INCLUDE 'F4COM.FOR'
      IE = 0
      IF(R) 2,9,3
2     R = -R
      PRBUFF(PRTPOS) = IMINUS
      PRTPOS = PRTPOS+1
C                                      CHOOSE E OR F FORMAT
3     S = R
      IF (R.GE.1.) GOTO 45
C                                      R .LT. 1.
41    IF (-IE.GE.IPOWER .OR. S.GE.1.) GOTO 44
      IE = IE-1
      S = S*10.
      GOTO 41
44    IF (-IE.LE.3) IE = 0
      GOTO 50
C                                      R .GE. 1.
45    IF (IE.GE.IPOWER .OR. S.LT.10.) GOTO 46
      IE = IE+1
      S = S/10.
      GOTO 45
46    U = S
      DO 48 I = 1,IRESOL
         IF (U.GE.1.) LEN = I
48       U = 10.*AMOD(U,1.)
C *** CHANGED BY TR
      IF(IE.LT.IRESOL)IE=O
C                                      NORMALIZE
50    IF (IE.NE.0) R = S
      R = R*(1.+FUZZ/S)
      NUM = R
      LIMIT = PRTPOS+IRESOL+1
C OUTPUT NUMBER OF INTEGERS WHICH CAN BE HANDELED BY PRIINT
C IF 10**IRESOL GT LARGEST INTEGER PRIINT MUST BE CALLED IN LOOP
51    IF(R.LT.MAXBIG)GOTO 52
      NUM=INT(R/RMAX)
      CALL PRIINT(NUM)
      R=AMOD(R,RMAX)
      GOTO 51
52    NUM=R
      IF (NUM.NE.0) CALL PRIINT(NUM)
C ***                                   DELETED STATEMENT(S). ***
      PRBUFF(PRTPOS) = DOT
      PRTPOS = PRTPOS+1
      IPOS0=PRTPOS
6     R = 10.*AMOD(R,1.)
      IF (R.EQ.0. .OR. PRTPOS.GE.LIMIT) GOTO 7
      NUM = R
      PRBUFF(PRTPOS) = IFIG(NUM+1)
      PRTPOS = PRTPOS+1
      IF (NUM.GT.0) IPOS0 = PRTPOS
      GOTO 6
C                                      STRIP ZEROS
7     IF (IPOS0.EQ.PRTPOS) GOTO 8
      PRTPOS = PRTPOS-1
      PRBUFF(PRTPOS) = SPACE
      GOTO 7
C                                      EXP. PART
8     IF (IE.EQ.0) RETURN
      PRBUFF(PRTPOS) = ECHAR
      PRTPOS = PRTPOS+1
9     CALL PRIINT(IE)
      RETURN
      END
      SUBROUTINE PRIINT(INUM)
        INCLUDE 'F4COM.FOR'
C                                      PRINT (-)INTEGER
      NUM = INUM
100   IF (NUM.GE.0) GOTO 101
      PRBUFF(PRTPOS) = IMINUS
      PRTPOS = PRTPOS+1
      NUM = -NUM
101   ISI = PRTPOS+19
C                                      THIS LOOP OUTPUTS DIGITS
      DO 270 I = 1,19
         JJ = MOD(NUM,10)+1
         PRBUFF(ISI) = IFIG(JJ)
         NUM = NUM/10
         IF (NUM.EQ.0) GOTO 280
270      ISI = ISI-1
280   K = PRTPOS+19
C                                      THIS LOOP POSITIONS THEM
      DO 290 I = ISI,K
         PRBUFF(PRTPOS) = PRBUFF(I)
         PRBUFF(I) = SPACE
290      PRTPOS = PRTPOS+1
      RETURN
      END
      SUBROUTINE TERPRI
        INCLUDE 'F4COM.FOR'
C             FIRST TEST IF CALLED FROM PRIN1
C             IF NOT, DO NOT WRITE ON LUNUT
      INTEGER*1 VPNAME
      EQUIVALENCE (VPNAME,PNAME)
      K = PRTPOS-1
      IF (IFLG2.EQ.T) GOTO 10
      IF(IFLG1 .NE. NIL) GOTO 20
      IF (K.LT.1) K=1
      CALL WRA1(LUNUT,PRBUFF,1,K)
      DO 1 I=1,K
1     PRBUFF(I)=SPACE
3     PRTPOS=LMARG
      RETURN
C                                      CALLED BY CONCAT
10    IF (NIL.EQ.MATOM(-K)) GOTO 22
      NATOMP = NATOMP-1
11    DO 12 I = 1,K
         CALL PUTCH(VPNAME,PRBUFF(I),JBP)
         PRBUFF(I) = SPACE
12       JBP = JBP+1
      PNP(NATOMP+1) = JBP
      PRTPOS = LMARG
      RETURN
C                                      CALLED BY NCHARS
20    IFLG1 = IFLG1+K
22    DO 24 I = 1,K
24       PRBUFF(I) = SPACE
      PRTPOS=1
      RETURN
      END
      SUBROUTINE IPRINT(I)
      CALL PRIN1(I)
      CALL TERPRI
      RETURN
      END
      FUNCTION IREAD(N)
        INCLUDE 'F4COM.FOR'
      INTEGER BRSTK,RATOM,CONS,X,Y,S1,SN
      EQUIVALENCE (X,TEMP1),(S1,TEMP2),(BRSTK,TEMP3)
C-----
C     IMPORTANT VARIABLES:
C
C     X         ATOM RETURNED BY  RATOM.
C               ALSO USED AS RETURN VALUE FROM RECURSIVE CALLS
C     IT        TYPE OF ATOM RETURNED BY  RATOM
C     S1        BEGINNING OF SUBLIST (LOCAL TO  LIST-L)
C     SN        LAST ELEMENT OF SUBLIST  S1  (LOCAL TO LIST-L)
C-----
C                                      INITIALIZE
      BRLEV = NUMADD
      BRSTK = NIL
      BRFLG = NIL
C                                      STACK RETURN ADDRESS
      CALL FPUSH(1)
      GOTO 190
C--R1
C                                      NORMAL RETURN FROM IREAD
100   IREAD = X
      RETURN
C
C                                      RECURSIVE RETURN
C
900   I = STACK(IP)
      IF (I.GT.4) GOTO 9000
      IP = IP-1
      GOTO (100,220,310,340),I
C
C--------------------------------------RECURSIVE PROCEDURE READ-S
C
190   IT = RATOM(X,1)
CDEBUG      WRITE(LUNUTS,191) IT
CDEBUG191   FORMAT(' IT AT 190 = ',I4)
200   GOTO (900,290,230,210,900),IT
C            A   (   )   '   .
210   CALL FPUSH(2)
      BRLEV = BRLEV + 1
      GOTO 190
C--R2
220   BRLEV = BRLEV - 1
      X = CONS(QUOTE,CONS(X,NIL))
      GOTO 900
C                                      ') OR '> ENCOUNTERED
230   BRLEV = BRLEV + 1
      GOTO 900
C
C--------------------------------------RECURSIVE PROCEDURE READ-L
C
290   S1 = NIL
      SN = NIL
300   IT = RATOM(X,1)
C                                      E-O-LIST
      IF (IT.EQ.3) GOTO 390
C                                      APPLY READ-S TO X
C                                      AND SET X = CONS(RESULT,NIL)
      IF (IT.EQ.1 .OR. IT.EQ.5) GOTO 320
      CALL FPUSH(3)
      CALL APUSH2(S1,SN)
      GOTO 200
C--R3
310   CALL APOP2(SN,S1)
320   X = CONS(X,NIL)
C                                      JUST INITIALIZE IF AT
C                                      BEGINNING OF LIST
      IF (S1.EQ.NIL) GOTO 330
C                                      TAKE CARE OF TRUE DOT
      IF (IT.NE.5 .OR. CAR(X).NE.DOTAT) GOTO 360
      CALL FPUSH(4)
      CALL APUSH2(S1,SN)
330   S1 = X
      SN = X
      GOTO 300
C--R4
340   CALL APOP2(SN,S1)
      Y = CDR(X)
      IF (Y.LE.NATOM .OR. Y.GT.NFREET) GOTO 350
      IF (CDR(Y).EQ.NIL) X = CAR(Y)
C*SETC*350   CALL SETCDR(SN, X)
350    CDR(SN)= X 
      GOTO 390
C                                      JUST APPEND X TO SN
C                                      AND GO ON LOOPING
C*SETC*360   CALL SETCDR(SN, X)
360    CDR(SN)= X 
      SN = X
      GOTO 300
C                                      X = RETURN(S1) FROM READ-L
390   X = S1
      GOTO 900
C--------------------------------------ERROR RETURNS
C
C  PDL OVERFLOW
9000  IREAD = NIL
      RETURN
      END
      INTEGER FUNCTION RATOM(X,IOP)
        INCLUDE 'F4COM.FOR'
      INTEGER CONS,X,BRSTK,CHTSAV
      DOUBLE PRECISION SUM(3),R,S,D
      REAL S1
      EQUIVALENCE (BRSTK,TEMP3)
C-----
C
C     IOP = 0        CALLED BY LISPF4
C           1        CALLED BY IREAD - DON'T RETURN <, >
C
C     CHR            CURRENT CHAR
C     CHT            TYPE OF CURRENT CHAR
C         = -1        EOF
C            0        EOL
C           >0        TYPE RETURNED FROM GETCHT
C     IRFLAG           FLAG FOR RECOGNIZING NUMBERS
C     ISIGN           FLAG FOR RECOGNIZING SIGN OF NUMATOM
C     ISUM            COUNTER TO PICK UP VALUE OF NUMATOM
C
C     RATOM = 1      ATOM
C             2      (     (X = NIL)
C             3      )     (X = NIL)
C             4      '     (X = NIL)
C             5      .     (X = .) !!
C-----
      RATOM = 1
      X = NIL
      IRFLAG = 1
      ISIGN = 1
      IF (BRFLG.EQ.NIL) GOTO 1010
      RATOM = 3
      GOTO 2040
C                                      SKIP DELIMITERS
1000  CALL SHIFT(2)
1010  IF (CHT.LE.1) GOTO 1000
      CHTSAV = CHT
      IF (CHT.LE.5) GOTO 2000
      IF (CHT.GE.25) CHT = 10
      IF (CHT.GE.13) GOTO 4101
      I = CHT-5
      GOTO (3000,3200,5000,4010,4100,4101,4000),I
C            "    '    UBR  .    A    +    -
C
C                                      BREAK CHARACTERS
C                                      (  )  <  >
C                                      SET-UP THE RETURN VALUE
2000  RATOM = CHT
      IF (CHT.GE.4) RATOM = CHT-2
      IF (IOP.EQ.0) GOTO 5000
C                                      CALLED BY IREAD
C                                      - KEEP TRACK OF ( ) < >
      I = CHT-1
      GOTO (2020,2040,2010,2030), I
C <                                    PUSH PARENTHESIS LEVEL
2010  BRSTK = CONS(BRLEV,BRSTK)
      BRLEV = NUMADD
C (
2020  BRLEV = BRLEV+1
      CHT = 0
      GOTO 6000
C >                                    BRFLG = T  WILL PREPARE FOR
C                                      VIRTUAL )'S
2030  BRFLG = T
C )
2040  BRLEV = BRLEV-1
      CHT = 0
      IF (BRLEV-NUMADD) 2045,2050,6000
C                                      ) OR > HAS BEEN ENCOUNTERED ON
C                                        TOP LEVEL - JUST RETURN NIL
2045  RATOM = 1
      GOTO 2060
C                                      ONE SUPER-BRACKED IS MATCHED
C                                      - POP PREVIOUS PARENTHESIS LEVEL
2050  BRLEV = CAR(BRSTK)
      BRSTK = CDR(BRSTK)
2060  BRFLG = NIL
      RETURN
C "                                    START OF STRING. READ
C                                       ALL OF IT.
3000  CALL SHIFT(2)
      I1CONS = MATOM(0)
      DO 3090 I = 1,MAXINT
         K = 1
         IF (CHT.EQ.6) GOTO 3100
         IF (CHT.LE.0) K = 3
3090     CALL SHIFT(K)
C                                      WHOLE STRING READ
3100  CALL SHIFT(3)
      X = I1CONS
      RETURN
C '                                    JUST SET-UP RETURN VALUE
3200  RATOM = 4
      IF (IOP.EQ.0) GOTO 5000
      CALL SHIFT(2)
      RETURN
C -                                    MAY BE BEGINNING OF NUMBER
4000  ISIGN = -1
      GOTO 4101
C .                                    MAY BE BEGINNING OF NUMBER
4010  IRFLAG = 2
      GOTO 4101
C A
4100  IRFLAG = 9
      GOTO 4110
C                                      THIS LOOP READS UNTIL BREAK-CHAR
C                                      - IF THE ATOM CAN BE INTERPRETED
C N                                       AS A NUMBER, IT WILL.
4101  SUM(1) = 0.
      SUM(2) = 0.
      SUM(3) = 0.
      IDIGS = 0
      NEW = -13
      DIV2 = 1.
      ISIGN3 = 1
      IF (CHT.LT.13) CHT = 13
4105  SUM(IRFLAG) = 10.*SUM(IRFLAG)+FLOAT(CHT-13)
4110  CALL SHIFT(1)
      IF (CHT.LT.9) GOTO 4500
      IF (IRFLAG.GT.3) GOTO 4110
      IF (CHT.GE.13 .AND. CHT.LT.23) GOTO 4200
      IF (CHT.GE.13) CHT = CHT-12
      I = CHT-8
      GOTO (4120,4100,4140,4150,4130,4100), I
C .                                    ALLOWED IF IRFLAG = 1
4120  IF (IRFLAG.GT.1) GOTO 4100
      IRFLAG = 2
      GOTO 4110
C E                                    ALLOWED IF IRFLAG = 1 OR 2
4130  IF (IRFLAG.GT.2) GOTO 4100
      IRFLAG = 3
      GOTO 4110
C +                                    ALLOWED IF IRFLAG = 3
4140  IF (IRFLAG-3) 4100,4110,4100
C -                                    ALLOWED IF IRFLAG = 3
4150  IF (IRFLAG.NE.3) GOTO 4100
      ISIGN3 = -1
      GOTO 4110
C DIGIT
4200  IF (IRFLAG.EQ.1 .AND. SUM(1).GT.0.) IDIGS = IDIGS+1
      IF (IRFLAG.EQ.2 .AND. SUM(1)+SUM(2).EQ.0.) IDIGS = IDIGS-1
      IF (IRFLAG.EQ.2) DIV2 = DIV2*10.
      GOTO 4105
C                                      END OF NUMBER
4500  IF (IRFLAG.GT.3) GOTO 5100
      IF (CHTSAV.LE.12 .AND. ABUP1.EQ.1) GOTO 5100
C                                      REAL NUMBER
      R = SUM(1)+SUM(2)/DIV2
      X = NUMADD
      IF (R.EQ.0.) GOTO 6000
      IE = ISIGN3*INT(SUM(3))
      IF (IE.GT. IPOWER-IDIGS) IE =  IPOWER-IDIGS
      IF (IE.LT.-IPOWER-IDIGS) IE = -IPOWER-IDIGS
4515  IF (IE) 4520,4590,4530
4520  IE = IE+1
      R = R/10.
      GOTO 4515
4530  IE = IE-1
      R = R*10.
      GOTO 4515
C                                      SMALL NUMBER
4590  S = R
      IF (ISIGN.LT.0) S = -R
      D=ISMALL
      IF (IRFLAG.GT.1      .OR. R.GT.D) GOTO 4591
      X = INT(S)+NUMADD
      GOTO 6000
4591  S1=S
      X = MKREAL(S1)
      GOTO 6000
C                                      USER BREAK CHARACTER
5000  CALL SHIFT(1)
C                                      RETURN STRING OR LITATOM
5100  X = MATOM(ABUP1)
C                                      SIGNAL IF IT IS A  .  WITHOUT  %
      IF (X.EQ.DOTAT .AND. CHTSAV.EQ.9) RATOM = 5
6000  ABUP1 = 0
      RETURN
      END
      SUBROUTINE SHIFT(I)
        INCLUDE 'F4COM.FOR'
      INTEGER GETCHT
C-----
C     I = 1       STORE PREVIOUS CHAR
C         2       DON'T STORE IT
C         3       STORE IN PNAME
C
C     IFLG2 = T   READ FROM PRBUFF   (CALLED BY PACK)
C             NIL READ FROM LUNIN    (CALLED BY RATOM)
C-----
C
1000  GOTO (1001,1010,1003), I
C                                      STORE PREVIOUS CHAR
1001  ABUP1 = ABUP1+1
         ABUFF(ABUP1) = CHR
1010  IF (IFLG2.NE.NIL) GOTO 2000
      GOTO 1100
C                                      STORE IN PNAME
1003  IF (NIL.EQ.MATOM(-ABUP1)) GOTO 1100
      NATOMP = NATOMP-1
      PNP(NATOMP+1) = PNP(NATOMP+2)
C                                      NOW CALLED BY RATOM
1100  IF (RDPOS.GT.MARGR) GOTO 1200
      CHR = RDBUFF(RDPOS)
      RDPOS = RDPOS+1
C                                      WAS PREVIOUS CHAR  %
C                                       THEN WE MUST HAVE COME
C                                        FROM DOWN BELOW.
      IF (CHT.NE.23) GOTO 1150
         CHT = 10
         J = GETCHT(CHR)
         IF (J.GE.11 .AND. J.LT.23) CHT=J
         RETURN
1150  CHT = GETCHT(CHR)
C                                      DON'T RETURN IF  %  IS READ
      IF (CHT.EQ.23) GOTO 1100
C                                      INPUT BREAK ?
      IF (CHT.NE.24) GOTO 1160
         ERRTYP = 27
         IBREAK = .TRUE.
         CHT = 10
1160  RETURN
C                                      NEW LINE
C                                      ** THIS IS THE ONLY CALL TO RDA1
1200  CALL RDA1(LUNIN,RDBUFF,1,MARGR,IEOF)
CDEBUG      WRITE(LUNUTS,1201)(RDBUFF(IIII),IIII=1,6)
CDEBUG1201  FORMAT(' RDBUFF=',6A5)
      IF (IEOF.EQ.2) GOTO 1300
      RDPOS = LMARGR
      CHT = 0
      RETURN
C                                      E-O-FILE
C*** CHANGED BY TR
1300  IF (LUNIN.NE.LUNINS) GOTO 1350
C        CALL MESS(32)
C        CALL LSPEX
C                                      ... BUT NOT ON LUNINS
C                                       SWITCH BACK TO LUNINS
1350  IF(LUNIN.NE.LUNINS) CALL REW(LUNIN)
      LUNIN = LUNINS
      CHT = -1
      RETURN
C----------------------------------------------------------
C                                      NOW CALLED BY PACK
C
C                                      HERE WE MAY RETURN IN CHT:
C                                       SEP. + - . DIGIT LETTER
C
C                                      ARG2 = MAX PRTPOS
C
2000  IF (PRTPOS.LE.ARG2) GOTO 2010
         CHT = 0
         RETURN
2010  CHR = PRBUFF(PRTPOS)
      PRTPOS = PRTPOS+1
      CHT = 10
      J = GETCHT(CHR)
      IF (J.GE.9 .AND. J.LT.23 .OR. J.GE.25) CHT = J
      RETURN
      END
      INTEGER FUNCTION GARB(GBCTYP)
        INCLUDE 'F4COM.FOR'
      INTEGER ARGS(10),S,RET,GBCTYP
      LOGICAL SPECAT
      INTEGER*2 JPNAME(1),JDUMMY
      INTEGER INDS(3),LENS(3),IPNAME(1),ARRLST
      INTEGER*1 VPNAME
      EQUIVALENCE (VPNAME,PNAME)
      EQUIVALENCE (ARG,ARGS(1))
      EQUIVALENCE (PNAME(1),IPNAME(1),JPNAME(1))
      SPECAT(JDUMMY) = JDUMMY.EQ.STRING .OR. JDUMMY.EQ.SUBSTR
     *            .OR. JDUMMY.EQ.ARRAY
C               GARB(GBCTYP) PERFORM GARBAGE COLLECTION DEPENDING ON GBC
C       GBCTYP = 0      NORMAL GBC, LIST CELLS ONLY (CALLED FROM CONS)
C                1      LIST COMPACTING (CALLED FROM ROLLOUT)
C                2      BIG NUMBERS COMPACTING (CALLED FROM MKNUM)
C                3      BIG NUMBERS AND ATOMS  (CALLED FROM MKATOM)
C
C STEP 1: MARK ACTIVE CELLS AND ATOMS BY NEGATIVE CDR.
C         IF FLOATING NUMBER GBC, MARK IN PNP.
C         IF GBCTYP < 1 GO TO STEP 2.
C STEP 3: LIST COMPACTING (GBCTYP = 1,2,3)
C         MOVE ACTIVE CAR,CDR TO TOP OF FREE STORAGE AND RESET CDR.
C         LEAVE NEW ADRESS IN CDR OF MOVED CELL.
C         IF GBCTYP < 2 GO TO STEP 2.
C STEP 5: FLOATING NUMBER GBC AND COMPACTING (GBCTYP = 2,3)
C         MOVE ACTIVE NUMBERS (MARKED IN PNP) TO TOP OF PNAME.
C         LEAVE NEW ADRESS IN OLD (LOWER) PNAME
C         RESET PNP
C         IF GBCTYP < 3 GO TO STEP 2.
C STEP 4: ATOM GBC AND COMPACTING (GBCTYP = 3)
C         MOVE ACTIVE ATOMS TO LOWER ATOM AREA (LOWER CAR,CDR)
C         LEAVE NEW ADRESS IN (NEGATIVE) HTAB AND RESET CDR.
C STEP 2: RESET CDR OF MARKED ATOMS.
C         IF GBCTYP < 1 GO TO STEP 7.
C STEP 6: RESTORE MOVED POINTERS (GBCTYP = 1,2,3)
C         CHECK ALL LIST POINTERS AND CHANGE TO
C         NEW VALUE IF MOVED.
C STEP 7: CLEAR MEMORY
C         MAKE FREE LIST
C         GBCTYP = 3: REHASH ALL SAVED ATOMS
C         RETURN
C
C STEP 1:
C
C             TRACE FROM ARG,ARG2,ARG3,FORM,ALIST,TEMP1,TEMP2,TEMP3,
C                        I1CONS,I2CONS; A-STACK; THE ATOMS.
C             ARG - I2CONS = ARGS(1) - ARGS(NARGS)
      ARRLST = NIL
      INREAL = BYTES/JBYTES
      NJP=JP
      ISUM=0
      ISPARE = NIL
C THE STACK
      I=1
177   S=JACK(I)
      IF(S.LE.0)GOTO 179
      RET=6
      GOTO 30
C R-6
178   S=JILL(I) 
      RET=7
      GOTO 30
C R-7
179   I=I+1
      IF(I.LE.TOPS)GOTO 177
C ARG-I2CONS
      RET=1
      I = 1
91    S=ARGS(I)
      GOTO 30
1     I = I+1
      IF (I.LE.NARGS) GOTO 91
C A-STACK
13    IF (JP.GT.NSTACK) GOTO 16
14    RET=2
      I = JP
92    S=STACK(I)
      GOTO 30
3     I = I+1
      IF (I.LE.NSTACK) GOTO 92
C ATOMS
16    I = 1
93    RET=3
      IF (SPECAT(CAR(I)) .OR. CDR(I).LT.0) GOTO 5
      S=CAR(I)
      GOTO 30
4     S=CDR(I)
      RET=4
      GOTO 30
5     I = I+1
      IF (I.LE.NATOMP) GOTO 93
C ARRAYS
      RET = 5
6     IF (ARRLST.LE.NIL) GOTO 99
      S = ARRLST
      ARRLST = -CDR(S)
C*SETC*      CALL SETCDR(S, -NIL)
       CDR(S)= -NIL 
      CALL ARRUTL(S,3,1,IND1,LEN)
      IND2 = IND1+LEN
7     IF (IND1.EQ.IND2) GOTO 6
      S = JPNAME(IND1)
      IND1 = IND1+1
      GOTO 30
99    IF (GBCTYP) 200,200,300
C             MARKL
C             RECURSIVE ROUTINE FOR MARKING LISTS
C             MARKL MAY CALL SUBROUTINE MARKL (NON-RECURSIVE ROUTINE)
C
C             RETURNPOINTS FOR MARKL
20    GOTO (1,3,4,5,7,178,179), RET
C                                      MARK WHAT  S  POINTS AT
30    IF (S.LE.T) GOTO 50
      IF (S.GT.NFREET) GOTO 45
      ICDR = CDR(S)
      IF (ICDR.LT.0) GOTO 50
C                                      AN ARRAY?
      IF (CAR(S).NE.ARRAY .OR. S.GT.NATOM) GOTO 32
C*SETC*      CALL SETCDR(S, -ARRLST)
       CDR(S)= -ARRLST 
      ARRLST = S
      GOTO 50
32    IF (IP.LT.JP-1) GOTO 35
C                                      RECURSION IN MARKL TOO DEEP
C                                      CALL SUBROUTINE MARKL
      IF (ISUM.EQ.1 .OR. DREG(1).EQ.NIL) GOTO 31
      ISUM = 1
      CALL MESS(24)
31    CALL MARKL(S,GBCTYP,ARRLST)
      GOTO 50
C                                      STACK SPACE LEFT. START MARKING
C*SETC*35    CALL SETCDR(S, -ICDR)
35     CDR(S)= -ICDR 
      JP = JP-1
      STACK(JP) = ICDR
C                                      MARK CAR
      S = CAR(S)
      GOTO 30
C                                      MARK A NUMBER
45    IF (S.GT.BIGNUM .OR. GBCTYP.LT.2) GOTO 50
      IS = S-NFREET
      IF (PNP(IS).GT.0) PNP(IS) = -PNP(IS)
C                                      RECURSIVE RETURN
50    IF (JP.EQ.NJP) GOTO 20
      S = STACK(JP)
C                                      MARK CDR
      JP = JP+1
      GOTO 30
C
C STEP 3: LIST COMPACTING ROUTINE
C
300   IBOT=NFREEB
      ITOP=NFREET
C             STEP ONE. MOVE ACTIVE CELLS TO THE TOP OF FS
301   IF (CDR(ITOP).GE.0) GOTO 315
C*SETC*      CALL SETCDR(ITOP, -CDR(ITOP))
       CDR(ITOP)= -CDR(ITOP )
306   ITOP=ITOP-1
      IF(IBOT-ITOP) 301, 328, 328
315   IF (CDR(IBOT).LT.0) GOTO 325
320   IBOT=IBOT+1
      IF(IBOT-ITOP) 315, 330, 330
C*SETC*325   CALL SETCAR(ITOP,CAR(IBOT))
325    CAR(ITOP)=CAR(IBOT )
C*SETC*      CALL SETCDR(ITOP,-CDR(IBOT))
       CDR(ITOP)=-CDR(IBOT )
C*SETC*      CALL SETCDR(IBOT,ITOP)
       CDR(IBOT)=ITOP 
      IBOT=IBOT+1
      GO TO 306
328   IF (CDR(ITOP).GE.0) GOTO 330
C*SETC*329   CALL SETCDR(ITOP,-CDR(ITOP))
329    CDR(ITOP)=-CDR(ITOP )
      ITOP=ITOP-1
330   NFREEP=ITOP
      GOTO (200,500,500), GBCTYP
C
C STEP 4: ATOM COMPACTING ROUTINE
C
C       MOVE UNUSED ATOMS. UNUSED IF:
C     CDR.GT.0 .AND. CASE(CAR) OF
C        (SPECIAL): T;  UNBOUND: CDR.EQ.NIL;  NIL;
C
C       FIRST CLEAR HTAB. HTAB IS USED FOR HOLDING MOVED POINTERS
400   NATOMO = NATOMP
      DO 420 I=1,NHTAB
420   HTAB(I)=0
      N=T
401   NATOMP = N+1
      JBP = PNP(NATOMP)
C                                      FIND ATOM TO MOVE
402   N=N+1
      IF(N .GT. NATOMO) GOTO 405
      IF(CDR(N) .LT. 0) GOTO 403
      IF (SPECAT(CAR(N))) GOTO 402
      IF (CAR(N).EQ.UNBOUN .AND. CDR(N).EQ.NIL) GOTO 402
403   IF (N.EQ.NATOMP) GOTO 401
C       MOVE ATOM(N) TO ATOM(NATOMP) AND MARK NEW ADRESS IN -HTAB(N)
      HTAB(N) = -NATOMP
C*SETC*      CALL SETCAR(NATOMP,CAR(N))
       CAR(NATOMP)=CAR(N )
C*SETC*      CALL SETCDR(NATOMP,CDR(N))
       CDR(NATOMP)=CDR(N )
C       MOVE PNAME(N) TO PNAME(NATOMP)
C       PNAME(NATOMP) STARTS IN (1,JBP), I.E. CURRENT PNAME-POINTERS.
      JB = PNP(N)
      IPL = PNP(N+1)-JB
      IF (IPL.EQ.0) GOTO 411
      IF (JB.NE.JBP) GOTO 4030
      JBP = JBP+IPL
      GOTO 411
4030  IF (CAR(N).NE.ARRAY) GOTO 409
      DO 4031 IREG = 1,3
4031     CALL ARRUTL(N,3,IREG,INDS(IREG),LENS(IREG))
      DO 4032 IREG = 1,3
4032     CALL ARRUTL(NATOMP,4,IREG,INDS(IREG),LENS(IREG))
      GOTO 419
409   DO 410 I = 1,IPL
      CALL GETCH(PNAME,ICH,JB)
      CALL PUTCH(VPNAME,ICH,JBP)
      JB=JB+1
410   JBP=JBP+1
411   PNP(NATOMP+1) = JBP
C       END OF MOVING PNAME
419   NATOMP = NATOMP+1
      GOTO 402
C       ALL ACTIVE ATOMS MOVED TO (1,NATOMP)
405   NATOMP=NATOMP-1
      GOTO 200
C       CONTINUE WITH STEP 5
C
C STEP 5: BIG NUMBERS COMPACTING
C
C       ALL ACTIVE BIG NUMBERS ARE MARKED NEGATIVE IN PNP.
C       OFFSETS FROM/TO INDEX IN CAR,INDEX IN PNP, INDEX IN PNAME ARE:
C       S -- I=S-NFREET --PNP(I) --J=I+DPNP -- PNAME(J)
C       S -- J=S+DPANME -- PNAME(J)
500   IBOT=1
      ITOP=NATOM
501   IF(PNP(ITOP) .GE. 0) GOTO 503
      PNP(ITOP)=-PNP(ITOP)
502   ITOP=ITOP-1
      IF(IBOT .GE. ITOP) GOTO 505
      GOTO 501
503   IF(PNP(IBOT) .LT. 0) GOTO 504
      IBOT=IBOT+1
      IF(IBOT .GE. ITOP) GOTO 506
      GOTO 503
504   I=ITOP+DPNP
      J=IBOT+DPNP
      PNAME(I)=PNAME(J)
      J = J*INREAL
      JPNAME(J) = ITOP+NFREET
      PNP(IBOT)=-PNP(IBOT)
      IBOT=IBOT+1
      GOTO 502
505   IF(PNP(ITOP) .GE. 0) GOTO 506
      PNP(ITOP)=-PNP(ITOP)
      ITOP=ITOP-1
506   NUMBP=ITOP+DPNP+1
      IF (GBCTYP.EQ.3) GOTO 400
C       NOW ALL ACTIVE NUMBERS ARE MOVED TO (PNAME(NUMBP), PNAME(NPNAME)
C
C STEP 2: RESTORE CDR OF ATOMS
C
200   DO 210 I = NIL,NATOMP
C*SETC*       IF (CDR(I).LT.0) CALL SETCDR(I, -CDR(I))
         IF (CDR(I).LT.0)  CDR(I)= -CDR(I )
210      CONTINUE
      IF (GBCTYP.LT.1) GOTO 700
C
C STEP 6: RESTORE MOVED POINTERS (GBCTYP 1,2,3)
C
C       CHECK ALL LIST POINTERS AND CHANGE VALUE IF MOVED.
600   NUMOVE=NUMBP-DPNAME
C THE STACK
C THE STACK
      I=1
560   S=JACK(I)
      IF(S.LE.0)GOTO 581
      IRET=6
      GOTO 650
C R-6
570   JACK(I)=S
      S=JILL(I) 
      IRET=7
      GOTO 650
C R-7
580   JILL(I)=S
581   I=I+1
      IF(I.LE.TOPS)GOTO 560
C ARG - I2CONS
      IRET = 1
      I = 1
601   IF (I.GT.NARGS) GOTO 610
      S = ARGS(I)
      GOTO 650
C<--
602   ARGS(I) = S
      I = I+1
      GOTO 601
C ASTACK
610   IRET = 2
      I = JP
611   IF (I.GT.NSTACK) GOTO 620
      S = STACK(I)
      GOTO 650
C<--
612   STACK(I) = S
      I = I+1
      GOTO 611
C ATOMS,LISTS,ARRAYS
620   I = NIL
621   IF (I.GT.NFREET) GOTO 710
      IF (I.EQ.NATOMP+1) I = NFREEP+1
      S = CAR(I)
      IRET = 3
      GOTO 650
C<--
C*SETC*622   CALL SETCAR(I, S)
622    CAR(I)= S 
      IF (S.NE.ARRAY .OR. I.GT.NATOM) GOTO 625
      CALL ARRUTL(I,3,1,IND1,LEN)
      IRET = 5
623   IF (LEN.LT.1) GOTO 625
      S = JPNAME(IND1)
      GOTO 650
C<--
624   JPNAME(IND1) = S
      IND1 = IND1+1
      LEN = LEN-1
      GOTO 623
625   S = CDR(I)
      IRET = 4
      GOTO 650
C<--
C*SETC*626   CALL SETCDR(I, S)
626    CDR(I)= S 
629   I = I+1
      GOTO 621
C
C CHANGE VALUE OF  S  IF NECESSARY
C
650   GOTO (656,654,652), GBCTYP
C A-GBC
652   IF (S.GT.NATOM) GOTO 654
      IF (HTAB(S).LT.0) S = -HTAB(S)
      GOTO 660
C N-GBC
654   IF (S.LE.NFREET) GOTO 656
      IF (S.GE.NUMOVE) GOTO 660
      ICAR = INREAL * (DPNAME+S)
      S = JPNAME(ICAR)
      GOTO 660
C C-GBC
656   IF (S.GE.NFREEB .AND. S.LE.NFREEP) S = CDR(S)
660   GOTO (602,612,622,626,624,570,580), IRET
C
C STEP 7: CLEAR MEMORY
C
C       NORMAL GBC. MAKE FREE LIST AND RETURN
700   NFREEP=NIL
      ISUM=0
      DO 702 I=NFREEB,NFREET
      IF(CDR(I) .GT. 0) GOTO 701
C*SETC*      CALL SETCDR(I,-CDR(I))
       CDR(I)=-CDR(I )
      GOTO 702
C*SETC*701   CALL SETCDR(I,NFREEP)
701    CDR(I)=NFREEP 
      NFREEP=I
      ISUM=ISUM+1
702   CONTINUE
      GARBS = GARBS+1
      MESSNR = 35
      GOTO 800
C       COMPACTING GARB. MAKE FREE LIST
710   MAX=NFREEP
      NFREEP=NIL
      DO 711 I=NFREEB,MAX
C*SETC*      CALL SETCDR(I,NFREEP)
       CDR(I)=NFREEP 
711   NFREEP=I
      GOTO (712,720,730), GBCTYP
C       CELL COMPACTING GARB
712   ISUM = NFREEP-NFREEB+1
      CGARBS=CGARBS+1
      MESSNR=3
      GOTO 800
C       NUMBER COMPACTING GARB.
720   ISUM = NUMBP-DPNP-2
      J = NUMBP-(JBP-2)/BYTES-3
      IF (J.LT.ISUM) ISUM = J
      NGARBS = NGARBS+1
      MESSNR=19
      GOTO 800
C       ATOM COMPACTING GARB
730   AGARBS=AGARBS+1
      ISUM=NATOM-NATOMP
      CALL REHASH
      MESSNR=38
C
C       EPILOGUE OF GARB. PRINT MESS IF MESSFLAG ON.
800   IF (DREG(1).EQ.NIL .OR. IFLG2.NE.NIL) GOTO 801
      CALL TERPRI
      CALL MESS(MESSNR)
      I = LUNUT
      LUNUT = LUNUTS
      PRTPOS = 12
      CALL PRIINT(ISUM)
      CALL TERPRI
      LUNUT = I
801   IF (ISUM.GT.15 .OR. GBCTYP.GE.1) GOTO 802

8011  CALL MESS(36)
C ----- !!!! -----
      CALL LISPF4(2)
C
C NOTE!  WE ARE NOT INTERESTED OF A RECURSIVE CALL TO LISPF4,
C        BUT JUST TO PERFORM A QUICK JUMP TO THE RESET ADDRESS.
C        IF YOUR RUNTIME SYSTEM COMPLAINS CHANGE THE PREVIOUS
C        CALL TO:
C     CALL LSPEX
C
802   GARB=ISUM
      RETURN
      END
      SUBROUTINE MARKL(IS,GBCTYP,ARRLST)
        INCLUDE 'F4COM.FOR'
C
C             A NON-RECURSIVE LIST TRAVELING ROUTINE WHICH USES THE
C             ALGORITHM DESCRIBED IN CACM AUG 67 (NR 8)
C
      INTEGER S,GBCTYP,ARRLST
C             AT ENTRY IS POINTS TO AN UNMARKED LIST-CELL
      I=NIL
      S=IS
C
C             FORWARD SCAN
C
1     ICDR=CDR(S)
      IF (CAR(S).NE.ARRAY .OR. S.GT.NATOM) GOTO 11
C*SETC*      CALL SETCDR(S, -ARRLST)
       CDR(S)= -ARRLST 
      ARRLST = S
      ICDR = S
      GOTO 2
11    IF (ICDR.GT.NFREET) GOTO 1024
12    IF (CDR(ICDR).LT.0) GOTO 24
C*SETC*13    CALL SETCDR(S,-I)
13     CDR(S)=-I 
      I=S
      S=ICDR
      GOTO 1
C
C             REVERSE SCAN
C
2     IF (I.EQ.NIL) GOTO 50
21    S=I
      IF (CAR(S).GE.0) GOTO 23
C             CELL MARKED AS BRANCH-POINT
22    I=-CAR(S)
C*SETC*      CALL SETCAR(S,ICDR)
       CAR(S)=ICDR 
      ICDR=S
      GOTO 2
C             NOT A BRANCH-POINT
23    I=-CDR(S)
C*SETC*24    CALL SETCDR(S,-ICDR)
24     CDR(S)=-ICDR 
      ICDR=S
      ICAR = CAR(S)
25    IF (ICAR.GT.NFREET) GOTO 1002
26    IF (CDR(ICAR).LT.0) GOTO 2
C             CAR(S) POINTS TO A SUBLIST
27    S=ICAR
C*SETC*      CALL SETCAR(ICDR,-I)
       CAR(ICDR)=-I 
      I=ICDR
      GOTO 1
C       DIFFERENT ENTRIES FOR NUMBERS
1024  IF(GBCTYP .LT. 2) GOTO 24
      IF(ICDR .GT. BIGNUM) GOTO 24
      IS=ICDR-NFREET
      IF(PNP(IS) .GT. 0) PNP(IS)=-PNP(IS)
      GOTO 24
1002  IF(GBCTYP .LT. 2) GOTO 2
      IF(ICAR .GT. BIGNUM) GOTO 2
      IS=ICAR-NFREET
      IF(PNP(IS) .GT. 0) PNP(IS)=-PNP(IS)
      GOTO 2
50    RETURN
      END
      SUBROUTINE REHASH
        INCLUDE 'F4COM.FOR'
      INTEGER HADR
      INTEGER*2 JDUMMY
      LOGICAL SPECAT
      SPECAT(JDUMMY) = JDUMMY.EQ.STRING. OR. JDUMMY.EQ.SUBSTR .OR.
     *  JDUMMY.EQ.ARRAY
C       USED TO GET A NEW ENTRY IN HTAB FOR AN EXISTING ATOM N.
C       CALLED BY ATOM GBC AND ROLLIN.
      DO 1 N=1,NHTAB
1     HTAB(N)=UNUSED
      DO 100 N=1,NATOMP
      IF (SPECAT(CAR(N))) GOTO 100
      JB = PNP(N)
      CALL GETCH(PNAME,ICH1,JB)
      L=PNP(N+1)-PNP(N)
20    CALL GETCH(PNAME,ICH2,JB+L/2)
      CALL GETCH(PNAME,ICH3,JB+L-1)
      HADR=IHADR(ICH1,ICH2,ICH3,NHTAB)
50    DO 51 I=1,NHTAB
      IF(HTAB(HADR) .EQ. UNUSED) GOTO 52
      HADR=HADR+1
      IF(HADR .LE. NHTAB) GOTO 51
      HADR=1
51    CONTINUE
52    HTAB(HADR)=N
100   CONTINUE
      RETURN
      END
      FUNCTION IHADR(ICH1,ICH2,ICH3,NHTAB)
C--
C-- THIS FUNCTION MAY NEED TO BE REWRITTEN FOR EFFICIENT
C-- HASHING ON SOME COMPUTERS (E.G. VAX-11)
C--
      IHADR=MOD(IABS(ICH1/7+ICH2/3+ICH3/5),NHTAB)+1
      RETURN
      END
      FUNCTION MATOM(K)
        INCLUDE 'F4COM.FOR'
        INTEGER GARB,HADR
      INTEGER*1 VPNAME
      EQUIVALENCE (VPNAME,PNAME)
C
C     K>0:  CREATE A LITERAL ATOM OF THE K BYTES IN ABUFF.
C     K<=0: CREATE A STRING OF LENGTH -K.  MOVE ABUP1 BYTES TO IT.
C
C     POINTERS USED: JBP (BYTE POINTER IN PNAME), IS UPDATED.
C                    NATOMP (ATOM POINTER), INCREASED BY 1.
C                    ABUP1 (POINTER IN ABUFF), IS RESET.
C                    NUMBP (BIGNUM POINTER IN PNAME).
C
C       FIRST CALCULATE HASH ADRESS.
      L = K
      IF(L .GT. 0) GOTO 100
C               MATOM IS TO MAKE A STRING
      L=-L
      HADR=0
      GOTO 30
C          MATOM IS TO MAKE A LITATOM
100   ABUP1 = L
      IF(DREG(4).EQ.T) CALL UPCASE(ABUFF,L)
      HADR=IHADR(ABUFF(1),ABUFF(1+L/2),ABUFF(L),NHTAB)
C       HASH ADRESS = HADR
C       LENGTH OF ATOM = L
C       SEARCH FOR EXISTING ATOM OR NEW ENTRY.
5       DO 20 I=1,NATOM
        IMATOM=HTAB(HADR)
        IF(IMATOM .EQ. UNUSED) GOTO 30
        JB = PNP(IMATOM)
        IPL = PNP(IMATOM+1)-JB
        IF(L .NE. IPL) GOTO 16
C               EQUAL LENGTHS. TEST CHARACTERS IN IBUFF - PNAME.
        DO 15 J=1,L
        CALL GETCH(PNAME,ICH1,JB)
        IF(ICH1 .NE. ABUFF(J)) GO TO 16
15      JB=JB+1
C               OLD ATOM FOUND. RETURN(IMATOM)
        GOTO 60
C               ATOM NOT FOUND, TRY NEXT.
16      HADR=HADR+1
        IF(HADR .GT. NHTAB) HADR=1
20      CONTINUE
C               NEW ATOM TO BE CREATED
30    IF (IBREAK .AND. ERRTYP.EQ.33) GOTO 56
      NALEFT = NATOM-NATOMP-1
      NBNOW  = BYTES*(NUMBP-2)-(JBP-1)
      NBLEFT = NBNOW-L
      IF (NALEFT.LT.0 .OR. NBLEFT.LT.0) GOTO 50
      IF (IBREAK) GOTO 35
      IF (NALEFT.EQ.9 .OR. NBNOW.GE.50.AND.NBLEFT.LT.50) GOTO 50
35    NATOMP = NATOMP+1
      IMATOM = NATOMP
C*SETC*      CALL SETCAR(IMATOM, STRING)
       CAR(IMATOM)= STRING 
C*SETC*      CALL SETCDR(IMATOM, NIL)
       CDR(IMATOM)= NIL 
      PNP(IMATOM+1) = JBP+L
C*SETC*      IF (HADR.GT.0) CALL SETCAR(IMATOM, UNBOUN)
      IF (HADR.GT.0)  CAR(IMATOM)= UNBOUN 
      IF (HADR.GT.0) HTAB(HADR)  = IMATOM
      IF (ABUP1.EQ.0) GOTO 60
C                                      MOVE CHARS TO PNAME
      DO 42 J = 1,ABUP1
         CALL PUTCH(VPNAME,ABUFF(J),JBP)
42       JBP = JBP+1
      GOTO 60
C             SPACE FOR NEW ATOM TOO SMALL.
C             PERFORM COMPACTING ATOM GBC.
50    NALEFT = GARB(3)-1
      NBLEFT = BYTES*(NUMBP-2)-(JBP-1)-L
      IF (NALEFT.LT.0 .OR. NBLEFT.LT.0) GOTO 56
      IF (.NOT.IBREAK) ERRTYP = 0
      IF (NALEFT.LT.10) ERRTYP = 28
      IF (NBLEFT.LT.50) ERRTYP = 37
      IF (ERRTYP.GT.0) IBREAK = .TRUE.
      IF (HADR) 35, 35, 100
C                                      ATOM SPACE EMPTY. NIL RETURNED
56    ERRTYP = 33
      IBREAK = .TRUE.
      IMATOM = NIL
C               RESET POINTER IN ABUFF AND RETURN(IMATOM)
60      ABUP1=0
      MATOM = IMATOM
        RETURN
        END
      INTEGER FUNCTION MKNUM(N)
        INCLUDE 'F4COM.FOR'
C
C               ROUTINE FOR MAKING A BIG INTEGER NUMBER.
C
      IF (N.LT.-ISMALL .OR. N.GT.ISMALL) GOTO 1
      MKNUM = N+NUMADD
      RETURN
1     MKNUM = MKREAL(FLOAT(N))
      RETURN
      END
      FUNCTION MKREAL(R)
        INCLUDE 'F4COM.FOR'
C
C                    ROUTINE FOR MAKING A FLOATING NUMBER
C
      INTEGER GARB
C                                      CHECK PRINTNAME SPACE
1     IF (IBREAK .AND. ERRTYP.EQ.25) GOTO 3
      NLEFT = NUMBP-(JBP-2)/BYTES-4
      IF (NLEFT.GE.0 .AND. NLEFT.NE.9) GOTO 11
      I = GARB(3)
C                                      CHECK AFTER GARB
      NLEFT = NUMBP-(JBP-2)/BYTES-4
      I = NUMBP-DPNP-3
      IF (I.LT.NLEFT) NLEFT = I
      GOTO 12
C                                      CHECK BIGNUM SPACE
11    NLEFT = NUMBP-DPNP-3
      IF (NLEFT.GE.0 .AND. NLEFT.NE.9) GOTO 2
      NLEFT = GARB(2)-1
12    IF (NLEFT.LT.0) GOTO 3
      IF (NLEFT.GE.10) GOTO 2
      ERRTYP = 21
      IBREAK = .TRUE.
C                                      MAKE THE NUMBER
2     NUMBP = NUMBP-1
      PNAME(NUMBP) = R
      MKREAL = NUMBP-DPNAME
      RETURN
C                                      BIGNUM SPACE EMPTY. 0 RETURNED
3     ERRTYP = 25
      IBREAK = .TRUE.
      MKREAL = NUMADD
      RETURN
      END
      INTEGER FUNCTION GETNUM(I)
        INCLUDE 'F4COM.FOR'
      IF (I.GT.BIGNUM) GOTO 1
      R = GTREAL(I,IRETUR)
      GETNUM = IRETUR
      RETURN
1     GETNUM = I-NUMADD
      RETURN
      END
      FUNCTION GTREAL(I,IRETUR)
        INCLUDE 'F4COM.FOR'
      IF (I.GT.BIGNUM) GOTO 1
      J = I+DPNAME
      R = PNAME(J)
      IRETUR = MAXBIG
      IF (R.LT.0.) IRETUR = -IRETUR
      IF (ABS(R).LT.BIGMAX) IRETUR = INT(R)
      GTREAL = R
      RETURN
C                                      SMALL INT. -- DON'T CONVERT
1     GTREAL = 0.
      IRETUR = I-NUMADD
      RETURN
      END
      INTEGER FUNCTION GETCHT(IC)
        INCLUDE 'F4COM.FOR'
C     I = IC/CHDIV+1
      I = MOD(IC,256)+1
      IF (IC.LT.0) I = NBYTES+I-1
      GETCHT=CHTAB(I)
      RETURN
      END
         SUBROUTINE SETCHT(IC,IT)
        INCLUDE 'F4COM.FOR'
      DIMENSION ICH(26)
      EQUIVALENCE (SPACE,ICH(1))
C      I = IC/CHDIV+1  
      I = MOD(IC,256)+1
      IF (IC.LT.0) I = NBYTES+I-1
      CHTAB(I)=IT
      ICH(IT)=IC
      RETURN
      END
      INTEGER FUNCTION NCHARS(S,IFLG)
        INCLUDE 'F4COM.FOR'
      INTEGER S,CONS
      CALL APUSH(PRTPOS)
      DO 1 I=1,MARG
         BUFF(I)=PRBUFF(I)
1        PRBUFF(I)=SPACE
      I = DREG(5)
      DREG(5)=IFLG
      IFLG1=NUMADD
      PRTPOS=1
2     IF (S.LE.NIL) GOTO 4
      IF (S.LE.NATOM .OR. S.GT.NFREET) S=CONS(S,NIL)
3     ICAR=CAR(S)
      CALL PRIN1(ICAR)
      S=CDR(S)
      GOTO 2
4     NCHARS = MKNUM(IFLG1+PRTPOS-1-NUMADD)
      IFLG1=NIL
      DREG(5) = I
      RETURN
C             AFTER CALLING NCHARS, NCHARS=THE NUMBER OF CHARS IN S,
C             PRBUFF=THE PRINTNAME OF S, BUFF=OLD PRBUFF.
C             CALLING ROUTINE MUST RESET PRBUFF AND PRTPOS
      END
      SUBROUTINE LSPEX
        INCLUDE 'F4COM.FOR'
C             EXIT ROUTINE
      INTEGER CONS
      LMARG = 12
      CALL TERPRI
      CALL MESS(4)
      CALL MESS(39)
      LUNUT = LUNUTS
      CALL IPRINT(CONS(MKNUM(GARBS),
     *              CONS(MKNUM(CGARBS),
     *                CONS(MKNUM(NGARBS),
     *                  CONS(MKNUM(AGARBS), NIL)))))
      CALL MESS(30)
      IF (.FALSE.) RETURN
      LMARG = 1
C        LINE ABOVE NEEDED IF YOU CAN SAVE CORE IMAGES
C        THAT YOU RUN AGAIN
      STOP
      END
      SUBROUTINE MESS(I)
        INCLUDE 'F4COM.FOR'
      IF (I.EQ.0) GOTO 10
      IF (I.GT.MAXMES) I = 31
1     NW = NBMESS/IBYTES
      I2 = NW*I
      CALL WRA4(LUNUTS,IMESS,(I2+1)-NW,I2)
      RETURN
C             READ MESSAGES FROM LUNSYS
10    I1=1
      I2 = NBMESS/IBYTES
      I3 = I2
      DO 20 K=1,MAXMES
      CALL RDA4(LUNSYS,IMESS,I1,I2)
      I1=I1 + I3
20    I2=I2 + I3
      RETURN
      END
      SUBROUTINE DMPIN2(LUN,CARD,I1,I2)
C             DMPIN2 IS CALLED ONLY FROM ROLLIN.
C             CARD MUST HAVE THE SAME DECLARATION AS CAR, CDR ...
        INCLUDE 'F4COM.FOR'
      INTEGER CARD(I2)
C      I3 = MAXREC/JBYTES
C      DO 10 I = I1,I2,I3
C        MAX = I+I3-1
C        IF (MAX.GT.I2) MAX = I2
C10      READ (LUN) (CARD(J), J = I,MAX)
10       READ (LUN) (CARD(J), J = I1,I2)
      RETURN
      END
      SUBROUTINE RDA4(LUN,CARD,I1,I2)
      INTEGER CARD(I2)
C             RDA4 IS CALLED FROM MESS
      READ(LUN,100) (CARD(I),I=I1,I2)
100   FORMAT (100A4)
      RETURN
      END
      SUBROUTINE DMPIN (LUN,AREA,I1,I2)
        INCLUDE 'F4COM.FOR'
      INTEGER AREA(I2)
C      I3 = MAXREC/IBYTES
C      DO 10 I = I1,I2,I3
C        MAX = I+I3-1
C        IF (MAX.GT.I2) MAX = I2
10       READ (LUN) (AREA(J), J = I1,I2)
        RETURN
        END
      SUBROUTINE DMPOU2(LUN,LINE,I1,I2)
C             DMPOU2 IS CALLED ONLY FROM ROLLOUT.
C            LINE MUST HAVE THE SAME DECLARATION AS CAR, CDR ...
        INCLUDE 'F4COM.FOR'
      INTEGER LINE(I2)
C     IF YOUR FORTRAN HAS A MAX RECORD LENGTH WHEN WRITING TO FILES
C     YOU MAY HAVE TO CHANGE BELOW. REMOVE LINE 10 AND THE COMMENTS
C     CHANGE MAXREC TO WHATEVER LENGT IS MAX ON YOUR COMPUTER
C      I3 = MAXREC/JBYTES
C      DO 10 I = I1,I2,I3
C        MAX = I+I3-1
C        IF (MAX.GT.I2) MAX = I2
C10      WRITE (LUN) (LINE(J), J = I,MAX)
10       WRITE (LUN) (LINE(J), J = I1,I2)
      RETURN
      END
      SUBROUTINE WRA1(LUN,LINE,I1,I2)
      INTEGER LINE(I2)
      INCLUDE 'F4COM.FOR'
C INSERTED BY TR:
      IF(LUN.EQ.LUNUTS)GOTO 1
      WRITE(LUN,100) (LINE(I),I=I1,I2)
      RETURN
1      WRITE(LUN,101)(LINE(I),I=I1,I2)
101   FORMAT(1X,150A1)
100   FORMAT(150A1)
      RETURN
      END
      SUBROUTINE RDA1(LUN,CARD,I1,I2,IEOF)
C             CALLED FROM SHIFT AND INIT2
      INTEGER CARD(I2)
      INCLUDE 'F4COM.FOR'
      COMMON /PROMPT/PROTXT(80),PROLEN
      INTEGER PROTXT,PROLEN
      IEOF=1
      IF (LUN.NE.LUNINS) GOTO 40
      IF (PRTPOS.GT.1) GOTO 20
      WRITE (LUNUTS,10) (PROTXT(I),I=1,PROLEN)
C10    FORMAT (1X,150A1)
10    FORMAT ($150A1)
      GOTO 40
20    K=PRTPOS-1
      WRITE(LUNUTS,101)(PRBUFF(I),I=1,K)
C101   FORMAT(1X,150A1)
101   FORMAT($150A1)
      DO 21 I=1,K
21    PRBUFF(I)=SPACE 
      PRTPOS=1
40    CONTINUE
      READ(LUN,100,END=1) (CARD(I),I=I1,I2)
100   FORMAT(150A1)
      RETURN
1     IEOF=2
      RETURN
      END
      FUNCTION MPNAME(X,BUFFER,MAX,IPL)
C-- MOVES THE PNAME OF X TO THE BUFFER IN PACKED FORM
C-- MPNAME LT 0  ERROR
C--        EQ 0  OK
C--        GT 0  TRUNCATION
      INCLUDE 'F4COM.FOR'
      INTEGER GETPN,X,MAX,IPL
      INTEGER*1 BUFFER(1)
      IF(GETPN(X,MAIN,JB,IPL).LT.0)GO TO 5
      DO 2 I=1,MAX
C2     CALL PUTCH(BUFFER,1H ,I)
2     CALL PUTCH(BUFFER,SPACE,I)
      MPNAME=0
      IF(IPL.LE.MAX)GO TO 3
      MPNAME=1
      IPL=MAX
3     DO 4 I=1,IPL
      CALL GETCH(PNAME,ICH,JB)
      CALL PUTCH(BUFFER,ICH,I)
4     JB=JB+1
      RETURN
5     MPNAME=-1
      RETURN
      END
      SUBROUTINE WRA4(LUN,LINE,I1,I2)
        INCLUDE 'F4COM.FOR'
      INTEGER LINE(I2)
        I3=1
        DO 10 I=I1,I2
          IF(LINE(I).NE.SPACE) I3=I
10        CONTINUE
        WRITE(LUN,101)(LINE(I),I=I1,I3)
C101   FORMAT(1X,100A4)
101   FORMAT(100A4)
      RETURN
      END
      SUBROUTINE DMPOUT(LUN,AREA,I1,I2)
        INCLUDE 'F4COM.FOR'
      INTEGER AREA(I2)
C      I3 = MAXREC/IBYTES
C      DO 10 I = I1,I2,I3
C        MAX = I+I3-1
C        IF (MAX.GT.I2) MAX = I2
10       WRITE (LUN) (AREA(J), J = I1,I2)
        RETURN
        END
      FUNCTION MSLFT(I)
      MSLFT=0
      RETURN
      END
      SUBROUTINE MTIME(IT)
      INTEGER IT
      RETURN
      END
      SUBROUTINE MDATE(IT)
      INTEGER*4 IT
      RETURN
      END
      FUNCTION OPENF(I)
      I=0
      RETURN
      END
      SUBROUTINE REW(LUN)
      REWIND LUN
      RETURN
      END
      SUBROUTINE EJECT(LUN)
      WRITE(LUN,100)
100   FORMAT(1H1)
      RETURN
      END
      INTEGER FUNCTION XCALL(FN,X)
      INCLUDE 'F4COM.FOR'
      INTEGER FN,X,A1,A2,A3,A4,GETNUM
      CHARACTER*50 C2,C3,C4
      GOTO (1000,2000), FN
      GOTO 10000
1000  IF (X .LE. NATOM  .OR.  X .GT. NFREET) GOTO 10000
      A1 = CAR(X)
      IF (A1 .LE. NFREET  .OR.  A1 .GT. MAXINT) GOTO 10000
      XCALL = A1
      A1 = GETNUM(A1)
      X = CDR(X)
      IF(X .LE. NATOM .OR. X .GT. NFREET) GOTO 10000
      A2 = CAR(X)
      IF(A2 .LT. NIL .OR. A2 .GT. NATOMP) GOTO 10000
      CALL MKCHA(A2,C2)
      X = CDR(X)
      IF(X .LE. NATOMP .OR. X .GT. NFREET) GOTO 10000
      A3 = CAR(X)
      IF(A3 .LE. NIL .OR. A3 .GT. NATOMP) GOTO 10000
      CALL MKCHA(A3,C3)
      X = CDR(X)
      IF(X .LE. NATOMP .OR. X .GT. NFREET) GOTO 10000
      A4 = CAR(X)
      IF(A4 .LE. NIL .OR. A4 .GT. NATOMP) GOTO 10000
      CALL MKCHA(A4,C4)
C
      OPEN(A1,ERR=10000,FILE=C2,STATUS=C3,FORM=C4)
C
      RETURN
C
 2000 IF(X .LE. NFREET .OR. X .GT. MAXINT) GOTO 10000
      A1 = GETNUM(X)
      CLOSE(A1,ERR=10000)
      XCALL=X
      RETURN
10000 XCALL = NIL
      RETURN
      END
      SUBROUTINE MKCHA(ADDR,A)
      INCLUDE 'F4COM.FOR'
C     RECUR 5
      INTEGER ADDR, IQQQ(50),IQQR,IQQN
      CHARACTER*50  A
C
C
C
      IQQR = PNP(ADDR)
      IQQN = PNP(ADDR+1)
C
      DO 60 I=1,IQQN-IQQR
   60 CALL GETCH(PNAME,IQQQ(I),IQQR-1+I)
C
C     A=CHAR(IQQQ(1)/CHDIV)
      A=CHAR(MOD(IQQQ(1),256))
      DO 70 I=2,IQQN-IQQR
C  70 A=A(1:I-1) // CHAR(IQQQ(I)/CHDIV)
   70 A=A(1:I-1) // CHAR(MOD(IQQQ(I),256))
C
C
      RETURN
      END
      SUBROUTINE BRSET
C-- THIS SUBROUTINE IS CALLED INITIALLY AND SHOULD SET UP TERMINAL
C-- INTERRUPTS SO THAT THE SUBROUTINE BRSERV IS CALLED WHENEVER THE
C-- USER TYPES AN INTERRUPT CHARACTER (E.G. CTRL-H ON DEC, 
C-- CTRL-C ON VAX11, BREAK ON IBM)
      RETURN
      END
