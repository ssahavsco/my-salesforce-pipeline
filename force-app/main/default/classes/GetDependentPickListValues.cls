/***********************************************************************************************************************************
Interface Name : GetDependentPickListValues
CreatedDate : 08-Dec-21
*! Description : controller class to pull the dependent picklist values for Resolution Type
* Created By : Sumit Saha

*Revision History
* TODO: 08/12/2020 Sumit S |  DP-46655  - Add Resolution Reason drop down list to 'Lost or Stolen Gift Card' resolution type
***********************************************************************************************************************************/

public class GetDependentPickListValues
   {
        public String validFor;
        @AuraEnabled(cacheable=true)

       public static List<String> getFieldDependencies(  String caseType, String objectName, String controllingField, String dependentField )
        {

            Map<String, List<String>> controllingInfo = new Map<String, List<String>>();

            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

            Schema.DescribeSObjectResult describeResult = objType.getDescribe();
            Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
            Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();

            List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
            List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

            for(Schema.PicklistEntry currControllingValue : controllingValues)
            {
                //System.debug('ControllingField: Label:' + currControllingValue.getLabel());
                controllingInfo.put(currControllingValue.getLabel(), new List<String>());
            }

            for(Schema.PicklistEntry currDependentValue : dependentValues)
            {
                String jsonString = JSON.serialize(currDependentValue);

                GetDependentPickListValues info = (GetDependentPickListValues) JSON.deserialize(jsonString, GetDependentPickListValues.class);

                String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();

                //System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);

                Integer baseCount = 0;

                for(Integer curr : hexString.getChars())
                {
                    Integer val = 0;

                    if(curr >= 65)
                    {
                        val = curr - 65 + 10;
                    }
                    else
                    {
                        val = curr - 48;
                    }

                    if((val & 8) == 8)
                    {
                        //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getLabel());
                        controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                    }
                    if((val & 4) == 4)
                    {
                        //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getLabel());
                        controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                    }
                    if((val & 2) == 2)
                    {
                        //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getLabel());
                        controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                    }
                    if((val & 1) == 1)
                    {
                        //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getLabel());
                        controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                    }

                    baseCount += 4;
                }            
            } 

           System.debug('ControllingInfo: ' + controllingInfo);
          // System.debug('ControllingInfo: ' + controllingInfo.get(caseType[0]));

             List<String> str  = new  List<String>();
             System.debug('Input From LWC: ' + caseType);
             str.addall((List<String>) controllingInfo.get(caseType));
             return str;
        }
}