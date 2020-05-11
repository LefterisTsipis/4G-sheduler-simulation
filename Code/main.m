

%***************       personal information   *************************************************
%
%
%             %Name             : Lefteris
%             %SurName          : Tsiphs
%             %UserName         : icsdm418006
%             %Email            : icsdm418006@icsd.aegean.gr
%             %Project          : " scheduler OFDM"    
%
%************************************************************************************************







%*****************************   global variables  ********************************************


 REPerB=84*2;
Category=[1,2,3];% 1:urban, 2:suburban,3:rural
F_HATA=[1500];%MHz
NoiceFigure=10; %dB
BI=15;
NoisePower= -174 +10*log10(180*10^3)+NoiceFigure+BI;
SINRmin=-9.3;%d
Lbody=3;%dB body loss
Lbpl=18;%dB building penetration loss
Lj=2;%jumber loos
Ga=5;% gain 


%***************************** end  global variables  ******************************************







%***************************** configuration of MeNB   ******************************************

MeNB(1).x=250;% x coordinate
MeNB(1).y=250;% y coordinate
MeNB(1).ChannelBandwidth=20;%MHz
MeNB(1).carrier=1.8*10^9;%MHz
MeNB(1).takeBitPerMilisec=100000;%MHz
MeNB(1).powerTransmit=35;  %dbm
MeNB(1).height=50; %metres

for i=1:20
MeNB(1).UEdata(i)=0;%MHz  
end

MaxPathLoss=Calculate_MaxPathLoss(MeNB(1).powerTransmit,NoisePower,SINRmin);

%*****************************  End configuration of MeNB   ******************************************







%*****************************   configuration of  20-UEs %*****************************************


%{

here we locate the Ues In the Grid

%}
x1=100;
s1=100;
s2=200;
s3=100;
s4=200;
s5=100;

for i=1:20
    if(i<=7)%1-7
        UE(i).x(1)=x1;% x coordinate
        UE(i).y=100;% y coordinate
       % UE(i).resurceBlock=setRB();
        UE(i).height=1.7;
         x1=x1+50;
    elseif (i>= 8) &&  (i<=9)%8-9
        x1=s2;
        UE(i).x(1)=x1;% x coordinate
        UE(i).y=180;% y coordinate
      %  UE(i).resurceBlock=setRB();
        UE(i).height=1.7;
        s2=s2+100;

     elseif (i>= 10) &&  (i<=11)
        x1=s3;
       UE(i).x(1)=x1;% x coordinate
        UE(i).y=250;% y coordinate
      %  UE(i).resurceBlock=setRB();
         UE(i).height=1.7;
        s3=s3+300;
     elseif (i>= 12) &&  (i<=13)
        x1=s4;
       UE(i).x(1)=x1;% x coordinate
        UE(i).y=320;% y coordinate
      %  UE(i).resurceBlock=setRB();
        UE(i).height=1.7;
        s4=s4+100;
    else
        x1=s5;
        UE(i).x(1)=x1;% x coordinate
        UE(i).y=400;% y coordinate
      % UE(i).resurceBlock=setRB();
       UE(i).height=1.7;
        s5=s5+50;
    end
    
end

for i=1:20
    cord_x(i)= UE(i).x;
    cord_y(i)= UE(i).y;
end


%*****************************  End  configuration of  20-UEs %*****************************************





%*****************************  scatter plot of  UEs and ENB %*****************************************


 cord_x(21)= MeNB(1).x;
 cord_y(21)= MeNB(1).y;
 
 scatter(cord_x,cord_y)
 
 
 

 
%***************************** End  scatter plot of  UEs and ENB %*****************************************
 
 





%*****************************   initialization phase of UEs        *****************************************

%{

here we calculate some parameters of the UEs before they moving(PL,SINR,CQI,Max throughput, max resurceBlock that the UE xan take )

%}


for i=1:20
 
 UE(i).distancefrom_eNB_m(1)=Distance(MeNB(1).x,MeNB(1).y,UE(i).x,UE(i).y);%metre 
 UE(i).PL_dB(1) =(HATA_Model((UE(i).distancefrom_eNB_m(1)/1000),F_HATA(1),MeNB(1).height, UE(i).height,Category(1)))+Lbody+Lbpl+Lj;
 %UE(i).PowerReceive_dBW=MeNB(1).powerTransmit -UE(i).PL_dB;
  UE(i).PowerReceive_dBmW(1)= MeNB(1).powerTransmit -UE(i).PL_dB+Ga;
  UE(i).SNR_dB(1)=UE(i).PowerReceive_dBmW-NoisePower;
  % UE(i).SNR_dB2=UE(i).PowerReceive_dBmW-NoisePower;
  UE(i).SNR(1)= 10^(UE(i).SNR_dB(1)/10);
  UE(i).CQI(1)=CQI_calculation(UE(i).SNR_dB(1));
  UE(i).MODULATION(1)= Modulation_calculation(UE(i).SNR_dB(1));
   UE(i).resurceBlock(1)=setRB(UE(i).SNR_dB(1));
   UE(i).throughput(1)=throughput_calculation( UE(i).MODULATION,UE(i).resurceBlock(1),UE(i).SNR_dB(1));
   
end

%{
Ues request service from provider
calcualation of servise priority
sheduler give as many resources as needed min{ can_decode,service_requires}
%}
for i=1:20
UE(i).QCI(1)=QCI_example_service();
UE(i).ExampleServise(1)=ExampleServise_calculation(UE(i).QCI);
UE(i).Priority=Priority_calculation(UE(i).QCI);
UE(i).Resource_Block_Allocation(1)=Resource_Block_Allocation_calculation( UE(i).QCI(1), UE(i).resurceBlock(1));
UE(i).throughput(1)=throughput_calculation( UE(i).MODULATION(1),UE(i).Resource_Block_Allocation(1), UE(i).SNR_dB(1));
end



%*****************************  End  initialization phase of UEs        *****************************************





%*****************************  Set the Ues in priority order         *****************************************


%{

serve clients based on priority

%}
T = struct2table(UE); % convert the struct array to a table
sortedT = sortrows(T, 'Priority'); % sort the table by 'DOB'
sortedUE = table2struct(sortedT); % change it back to st


%*****************************  End Set the Ues in priority order         *****************************************




 
%*****************************          Start  Simulation                  ***************************************** 
%{%} 
  % 1800000/2;
 NumberOfSubframes= 10000
sumThroughput=0;
mean_throughputPerTTI(1)=0

sumSNR_dB=0;
mean_SNR_dBPerTTI(1)=0


 MeNB(1).throughputPerTTI(1)=0 
for j=2:NumberOfSubframes 

            for i=1:20
                sortedUE(i).distancefrom_eNB_m(j)=sortedUE(i).distancefrom_eNB_m(j-1)+(138*10^(-5));%metre 
                sortedUE(i).PL_dB(j) =(HATA_Model((sortedUE(i).distancefrom_eNB_m(j)/1000),F_HATA(1),MeNB(1).height, sortedUE(i).height,Category(1)))+Lbody+Lbpl+Lj;
                 sortedUE(i).PowerReceive_dBmW(j)= MeNB(1).powerTransmit -sortedUE(i).PL_dB(j)+Ga;
                 sortedUE(i).SNR_dB(j)=sortedUE(i).PowerReceive_dBmW(j)-NoisePower;
                sortedUE(i).CQI(j)=CQI_calculation(sortedUE(i).SNR_dB(j)); 
                sortedUE(i).MODULATION(j)= Modulation_calculation(sortedUE(i).SNR_dB(j));
                sortedUE(i).resurceBlock(j)=setRB(sortedUE(i).SNR_dB(j));
                 sortedUE(i).Resource_Block_Allocation(j)=Resource_Block_Allocation_calculation( sortedUE(i).QCI(1), sortedUE(i).resurceBlock(j));
               sortedUE(i).throughput(j)=throughput_calculation( sortedUE(i).MODULATION(j),sortedUE(i).Resource_Block_Allocation(j), sortedUE(i).SNR_dB(1));
               sumThroughput=sumThroughput+sortedUE(i).throughput(j);
               sumSNR_dB=sumSNR_dB+sortedUE(i).SNR_dB(j);
                
            end 
           
           % MeNB(1).throughputPerTTI(j)=sum; 
            mean_throughputPerTTI(j)=round(sumThroughput/20);
            mean_SNR_dBPerTTI(j)=round(sumSNR_dB/20);
            sumThroughput=0;
            sumSNR_dB=0;
          
           
    
end
 





%*****************************          End   Simulation                  ***************************************** 








 %%%%%%%%%%%  %%%%%%%%%%%  %%%%%%%%%%%  PLOTS %%%%%%%%%%%  %%%%%%%%%%%  %%%%%%%%%%%  %%%%%%%%%%% 


Resource_Block_Comparison_BarChar=[  UE(1).resurceBlock UE(1).Resource_Block_Allocation;
    UE(2).resurceBlock UE(2).Resource_Block_Allocation;
    UE(3).resurceBlock UE(3).Resource_Block_Allocation;
    UE(4).resurceBlock UE(4).Resource_Block_Allocation;
    UE(5).resurceBlock UE(5).Resource_Block_Allocation;
    UE(6).resurceBlock UE(6).Resource_Block_Allocation;
    UE(7).resurceBlock UE(7).Resource_Block_Allocation;
    UE(8).resurceBlock UE(8).Resource_Block_Allocation;
    UE(9).resurceBlock UE(9).Resource_Block_Allocation;
    UE(10).resurceBlock UE(10).Resource_Block_Allocation;
    UE(11).resurceBlock UE(11).Resource_Block_Allocation;
    UE(12).resurceBlock UE(12).Resource_Block_Allocation;
    UE(13).resurceBlock UE(13).Resource_Block_Allocation;
    UE(14).resurceBlock UE(14).Resource_Block_Allocation;
    UE(15).resurceBlock UE(15).Resource_Block_Allocation;
    UE(16).resurceBlock UE(16).Resource_Block_Allocation;
    UE(17).resurceBlock UE(17).Resource_Block_Allocation;
    UE(18).resurceBlock UE(18).Resource_Block_Allocation;
    UE(19).resurceBlock UE(19).Resource_Block_Allocation;
    UE(20).resurceBlock UE(20).Resource_Block_Allocation;
    ];
 x=[1:20];
 
 bar(x,Resource_Block_Comparison_BarChar);
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plot(mean_SNR_dBPerTTI(2:10000),mean_throughputPerTTI(2:10000))
