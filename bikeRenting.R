#CHECK THE DISTRIBUTION OF CATEGORICAL DATA USING BAR GRAPH
BAR1 = GGPLOT(DATA = DAY, AES(X = season)) + GEOM_BAR() + GGTITLE("COUNT OF SEASON")
BAR2 = GGPLOT(DATA = DAY, AES(X = weathersit)) + GEOM_BAR() + GGTITLE("COUNT OF
                                                                             WEATHER")
BAR3 = GGPLOT(DATA = DAY, AES(X = holiday)) + GEOM_BAR() + GGTITLE("COUNT OF HOLIDAY") BAR4 = GGPLOT(DATA = DAY, AES(X = workingday)) + GEOM_BAR() + GGTITLE("COUNT OF WORKING DAY")
GRIDEXTRA::GRID.ARRANGE(BAR1,BAR2,BAR3,BAR4,NCOL=2) #CHECK THE DISTRIBUTION OF NUMERICAL DATA USING HISTOGRAM
HIST1 = GGPLOT(DATA = DAY, AES(X =temp)) + GGTITLE("DISTRIBUTION OF TEMPERATURE") +
  GEOM_HISTOGRAM(BINS = 25)
HIST2 = GGPLOT(DATA = DAY, AES(X =hum)) + GGTITLE("DISTRIBUTION OF HUMIDITY") +
  GEOM_HISTOGRAM(BINS = 25)
HIST3 = GGPLOT(DATA = DAY, AES(X =atemp)) + GGTITLE("DISTRIBUTION OF FEEL TEMPERATURE") + GEOM_HISTOGRAM(BINS = 25)
HIST4 = GGPLOT(DATA = DAY, AES(X =windspeed)) + GGTITLE("DISTRIBUTION OF WINDSPEED") +
  GEOM_HISTOGRAM(BINS = 25)
GRIDEXTRA::GRID.ARRANGE(HIST1,HIST2,HIST3,HIST4,NCOL=2) #CHECK THE DISTRIBUTION OF NUMERICAL DATA USING SCATTERPLOT
SCAT1 = GGPLOT(DATA = DAY, AES(X =temp, Y = CNT)) + GGTITLE("DISTRIBUTION OF
                                                                   TEMPERATURE") + GEOM_POINT() + XLAB("TEMPERATURE") + YLAB("BIKE COUNT")
SCAT2 = GGPLOT(DATA = DAY, AES(X =hum, Y = CNT)) + GGTITLE("DISTRIBUTION OF HUMIDITY") +
  GEOM_POINT(COLOR="RED") + XLAB("HUMIDITY") + YLAB("BIKE COUNT")
SCAT3 = GGPLOT(DATA = DAY, AES(X =atemp, Y = CNT)) + GGTITLE("DISTRIBUTION OF FEEL TEMPERATURE") + GEOM_POINT() + XLAB("FEEL TEMPERATURE") + YLAB("BIKE COUNT")
SCAT4 = GGPLOT(DATA = DAY, AES(X =windspeed, Y = CNT)) + GGTITLE("DISTRIBUTION OF
                                                                        WINDSPEED") + GEOM_POINT(COLOR="RED") + XLAB("WINDSPEED") + YLAB("BIKE COUNT")
GRIDEXTRA::GRID.ARRANGE(SCAT1,SCAT2,SCAT3,SCAT4,NCOL=2) #CHECK FOR OUTLIERS IN DATA USING BOXPLOT
CNAMES = COLNAMES(DAY[,C("temp","atemp","windspeed","hum")]) FOR (I in 1:LENGTH(CNAMES))
{
  ASSIGN(PASTE0("GN",I), GGPLOT(AES_STRING(Y = CNAMES[I]), DATA = DAY)+ STAT_BOXPLOT(GEOM = "ERRORBAR", WIDTH = 0.5) + GEOM_BOXPLOT(OUTLIER.COLOUR="RED", FILL = "GREY"
                                                                                                                                    
                                                                                                                                    ,OUTLIER.SHAPE=18, OUTLIER.SIZE=1, NOTCH=FALSE) + THEME(LEGEND.POSITION="BOTTOM")+ LABS(Y=CNAMES[I]) + GGTITLE(PASTE("BOX PLOT FOR",CNAMES[I])))
}
GRIDEXTRA::GRID.ARRANGE(GN1,GN3,GN2,GN4,NCOL=2)
#REMOVE OUTLIERS IN WINDSPEED
VAL = DAY[,19][DAY[,19] %IN% BOXPLOT.STATS(DAY[,19])$OUT] DAY = DAY[WHICH(!DAY[,19] %IN% VAL),]
#CHECK FOR MULTICOLLINEARITY USING VIF
DF = DAY[,C("instant","temp","atemp","hum","windspeed")] VIFCOR(DF)
#CHECK FOR COLLINEARITY USING CORELATION GRAPH
CORRGRAM(DAY, ORDER = F, UPPER.PANEL=PANEL.PIE, TEXT.PANEL=PANEL.TXT, MAIN = "CORRELATION PLOT")
#REMOVE THE UNWANTED VARIABLES DAY <- SUBSET(DAY, SELECT = -
C(instant,dteday,atemp,casual,registered,temp,atemp,windspeed,hum,season,yr,holiday,weathersit)
# DECISION TREE        DIVIDE THE DATA INTO TRAIN AND TEST
SET.SEED(123)
TRAIN_INDEX = SAMPLE(1:NROW(DAY), 0.8 * NROW(DAY)) TRAIN = DAY[TRAIN_INDEX,]
TEST = DAY[-TRAIN_INDEX,] #RPART FOR REGRESSION
DT_MODEL = RPART(CNT ~ ., DATA = TRAIN, METHOD = "ANOVA") #PREDICT THE TEST CASES
DT_PREDICTIONS = PREDICT(DT_MODEL, TEST[,-11]) #CREATE DATAFRAME FOR ACTUAL AND PREDICTED VALUES
DF = DATA.FRAME("ACTUAL"=TEST[,11], "PRED"=DT_PREDICTIONS)
HEAD(DF)
#CALCULATE MAPE
REGR.EVAL(TRUES = TEST[,11], PREDS = DT_PREDICTIONS, STATS = C("MAE","MAPE"))

#RANDOM FOREST      TRAIN THE DATA USING RANDOM FOREST
RF_MODEL = RANDOMFOREST(CNT~., DATA = TRAIN, NTREE = 700) #PREDICT THE TEST CASES
RF_PREDICTIONS = PREDICT(RF_MODEL, TEST[,-11]) #CREATE DATAFRAME FOR ACTUAL AND PREDICTED VALUES
DF = CBIND(DF,RF_PREDICTIONS) HEAD(DF)
#CALCULATE MAPE
REGR.EVAL(TRUES = TEST[,11], PREDS = RF_PREDICTIONS, STATS = C("MAE","MAPE"))
# LINEAR REGRESSION    TRAIN THE DATA USING LINEAR REGRESSION
LR_MODEL = LM(FORMULA = CNT~., DATA = TRAIN) #CHECK THE SUMMARY OF THE MODEL SUMMARY(LR_MODEL)
#PREDICT THE TEST CASES
LR_PREDICTIONS = PREDICT(LR_MODEL, TEST[,-11	]) #CREATE DATAFRAME FOR ACTUAL AND PREDICTED VALUES
DF = CBIND(DF,LR_PREDICTIONS) HEAD(DF)
#CALCULATE MAPE
REGR.EVAL(TRUES = TEST[,11], PREDS = LR_PREDICTIONS, STATS = C("MAE","MAPE")) #PREDICT A SAMPLE DATA
PREDICT(LR_MODEL,TEST[2,])
