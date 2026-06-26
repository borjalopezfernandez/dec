# General Configuration

The general configuration file *dec_incoming_files.xml* carries the items to drive pull circulations from the defined interfaces.

[]{#decincomingfilesxml label="decincomingfilesxml"}

# Example dec_incoming_files.xml

    <?xml version="1.0" encoding="UTF-8"?>

    <Config>

       <ListInterfaces xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

       <Interface>
          <Name>ECDC</Name>
          <LocalInbox>/tmp/dec/in_basket_if_ecdc</LocalInbox>
          <DownloadDirs>
              <Directory DepthSearch="0">covid19/casedistribution/csv</Directory>
          </DownloadDirs>
          <Switches>
             <DeleteDownloaded>false</DeleteDownloaded>
             <DeleteDuplicated>false</DeleteDuplicated>
             <DeleteUnknown>false</DeleteUnknown>
             <LogDuplicated>false</LogDuplicated>
             <LogUnknown>false</LogUnknown>
             <MD5>false</MD5>
          </Switches>
       
       </ListInterfaces>

       <DownloadRules xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

          <File Type="csv">
             <Description>Comma Separated Value</Description>
             <FromList>
                <Interface>ECDC</Interface>
             </FromList>
          </File>

     </DownloadRules>

       <DisseminationRules xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

       <ListIntrays>

          <Intray>
               <Name>DIAS</Name>
               <Directory>/tmp/dec_final_dissemination/DIAS/</Directory>
          </Intray>

       </ListIntrays>

          <ListFilesDisseminated>

          <!--
               SORT Rules ranking from more restrictive ones    
               Only the first rule matching the file pattern is applied     
           -->

             <File Type="S2?_*OPENHUB*.csv">
                <HardLink>false</HardLink>
                   <ToList>
                      <Intray>DIAS</Intray>
                   </ToList>
             </File>

    </Configuration>
