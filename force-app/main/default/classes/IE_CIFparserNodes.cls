/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         IE_CIFparser 
Description:   Class with the Parser methods used by the IntegrationEngine.
            The Parser takes the XML response convert it in a JSON object.
            The objects and field to be searched are specified in the Resposnse type placeholders.

History
-04/01/2015   Davide Fabris - Created
----------------------------------------------------------------------------*/
/**
 * @description PURE IT 22/05 - commentata la classe
 */
public class IE_CIFparserNodes {} 
/** PURE IT
implements IE_ResponseParser {


    public string ParseResponse(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs, string RawResponse) {
        String parsedResponse = 'ECHO from CIFparse'+RawResponse;
        
        //these should be retrieved from placeholders, or junctionObj. TO BE DONE
        Set<String> Objs = new Set<String>();
        Set<String> Fields = new Set<String>();
        Set<String> Lists = new Set<String>();

        Lists.add('listaNodiOutput');
        Lists.add('nodo');


        //Objs.add('return');
        Objs.add('listaNdgOutput');//when adding 1 node to many accounts
        Objs.add('listaNodiOutput');//when adding many nodes to a single account
        Objs.add('listaNodiAggiornata');//when adding many nodes to a single account
        //Objs.add('return');
        


        Fields.add('ndg');//when adding 1 node to many accounts
        Fields.add('nodo');//when adding many nodes to a single account
        Fields.add('esito');
        Fields.add('descrizioneEsito');

        
        
        DOM.Document myDOM = new DOM.Document();
        myDOM.load(RawResponse);
        DOM.XMLNode rootElement = myDOM.getRootElement();
        
        //instantiate the Json generator
        JSONGenerator JSgen = JSON.createGenerator(true);
        JSgen.writeStartObject(); //start root object

        
        for(DOM.XMLNode xmlnodeobj :myDOM.getRootElement().getChildElements() ) { //running through first level childs
            system.debug('+++++FIRST level------------XMLNODE getName()'+xmlnodeobj.getName());
            system.debug('+++++FIRST level------------XMLNODE getNodeType()'+xmlnodeobj.getNodeType());
            system.debug('+++++FIRST level------------XMLNODE getText()'+xmlnodeobj.getText());
            
            loadChilds(xmlnodeobj, OBjs, Fields, Lists, JSgen);   
            
        }
        
        JSgen.writeEndObject(); //close root object
        parsedResponse = JSgen.getAsString();

        return parsedResponse ;
    }
    
    //loading the child elements
    private void loadChilds(DOM.XMLNode xmlnode, Set<String> Objs,Set<String> Fields,Set<String> Lists, JSONGenerator JSgen)  {
        // I must check if i get a list of things (same name element will end up in an array)
        List<Dom.XMLNode> ChildNodes = xmlnode.getChildElements();
        map<string,integer> MapTag_to_TOT = new Map<string, integer>();
        map<string,integer> MapTag_to_counting = new Map<string, integer>();

        
        //in this first loop i check how many items each array has
        for(Dom.XMLNode child : ChildNodes)  {
            system.debug('+++++ Counting NESTED level------------XMLNODE getName()'+child.getName());
            system.debug('+++++ Counting NESTED level------------XMLNODE getNodeType()'+child.getNodeType());
            system.debug('+++++ Counting NESTED level------------XMLNODE getText()'+child.getText());
            integer currentCount = MapTag_to_TOT.get(child.getName());
            if (currentCount>0) {
                MapTag_to_TOT.put(child.getName(),currentCount+1);
            } else {
                MapTag_to_TOT.put(child.getName(),1);
                MapTag_to_counting.put(child.getName(),0);
            }
        }
        system.debug('+++++++++++counted this many childs'+MapTag_to_TOT);
        
        //in this second loop i populate the JSON
        for(Dom.XMLNode child : ChildNodes)  {
            system.debug('+++++NESTED level------------XMLNODE getName()'+child.getName());
            system.debug('+++++NESTED level------------XMLNODE getNodeType()'+child.getNodeType());
            system.debug('+++++NESTED level------------XMLNODE getText()'+child.getText());
            
            //Sorting out the structure of the objects
            integer current = MapTag_to_counting.get(child.getName());
            integer tot = MapTag_to_TOT.get(child.getName());

            if (OBjs.contains(child.getName())) {
                system.debug('+++++opening obj'+child.getName());
                
                if (current==0){ //write the field name only the first time
                    JSgen.writeFieldName(child.getName());
                    if (tot>1 || (tot==1 && Lists.contains(child.getName()))) {// if i need to write more than one open array
                        system.debug('++++++opened array for '+MapTag_to_TOT.get(child.getName())+ '--'+child.getName());
                        JSgen.writeStartArray();
                    }
                }

                system.debug('+++++WRITING' +current+1+'of'+tot+' ELEMENTS');
                JSgen.writeStartObject(); 
                MapTag_to_counting.put(child.getName(),current+1);
                current = MapTag_to_counting.get(child.getName());
            } 
            
            //Now that the structure is sorted out I can populate the fields
            if  (Fields.contains(child.getName())) {
                if (current==0){
                    JSgen.writeFieldName(child.getName());
                    if(tot>1 || Lists.contains(child.getName())){
                        JSgen.writeStartArray();
                    }
                }
                
                system.debug('+++++WRITING' +current+1+'of'+tot+' ELEMENTS');
                JSgen.writeString(child.getText());
                system.debug('+++++WRITTEN' +current+1+'of'+tot+' ELEMENTS');
                MapTag_to_counting.put(child.getName(),current+1);
                current = MapTag_to_counting.get(child.getName());
                
                if((tot>1 && current==tot ) || (tot==1 && Lists.contains(child.getName()))){
                    JSgen.writeEndArray();
                }
            }
            
            loadChilds(child,Objs,Fields, Lists, JSgen);    
            
            if (OBjs.contains(child.getName())) {
                system.debug('+++++Closing obj'+child.getName());
                system.debug('+++++WRITTEN' +current+'of'+tot+' ELEMENTS');
                JSgen.writeEndObject(); 
                
                if ((tot>1 && current==tot) || (tot==1 && Lists.contains(child.getName()))) {//should close the array
                    system.debug('++++++CLOSED array for '+MapTag_to_TOT.get(child.getName())+ '--'+child.getName());
                    JSgen.writeEndArray();
                }
            }
        }
    }
    // This is an extra function to read data between opening and closing tag. 
    // It will return the string of value from between tags
    public string getValueFromTag(XMLStreamReader reader) {
        String DataValue='';
        
        while (reader.hasNext()) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                break;
            } else if (reader.getEventType() == XmlTag.CHARACTERS) {
                DataValue = reader.getText();
            }
            reader.next();
        }
        
        return DataValue;
    }
    
    

}
PURE IT */