# Interface Configuration

The general configuration file *dec_interfaces.xml* carries the items TBW TBW TBW.

[]{#decinterfacesxml label="decinterfacesxml"}

# Example dec_interfaces.xml


    <?xml version="1.0" encoding="UTF-8"?>
    <Interfaces xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

      <Interface Name="IERS">
         
         <Desc>IERS Interface</Desc>
         
         <TXRXParams>
             <Enabled4Sending>false</Enabled4Sending>
             <Enabled4Receiving>true</Enabled4Receiving>
             <ImmediateRetries>3</ImmediateRetries>
             <LoopRetries>2</LoopRetries>
             <LoopDelay unit="s">300</LoopDelay>
             <PollingInterval unit="s">20</PollingInterval>
             <PollingSize>470</PollingSize>
             <ParallelDownload>5</ParallelDownload>
         </TXRXParams>    

         <Server>
            <Protocol>FTP</Protocol>
            <Hostname>ftp.iers.org</Hostname>
            <Port>21</Port>
            <User>anonymous</User>
            <Pass>guest</Pass>
            <RegisterContentFlag>false</RegisterContentFlag>
            <RetrieveContentFlag>true</RetrieveContentFlag>
            <SecureFlag>false</SecureFlag>
            <VerifyPeerSSL>false</VerifyPeerSSL>
            <CompressFlag>false</CompressFlag>
            <PassiveFlag>true</PassiveFlag>
            <CleanUpFreq Unit="s">5</CleanUpFreq>
         </Server>
         
         <DeliverByMailTo>
              <Address>mario.bross@gmail.com</Address>
         </DeliverByMailTo>

       <Notify>
          <SendNotification>false</SendNotification>
          <To>
            <Address>mario.draghi@supereuro.com</Address>
           </To>
       </Notify>

       <Events>
          <Event Name="NewFile2InTray"          executeCmd="auxConverter -f %F" />
       </Events>

       <ContactInfo>
          <Name>Mr draghi</Name>
          <EMail>mario.draghi@supereuro.com</EMail>
          <Tel>0039-800 454 432</Tel>
          <Fax>0039-800 454 433</Fax>
         <Address>Citta Uova</Address>
       </ContactInfo>

       </Interface>

    </Interfaces>
