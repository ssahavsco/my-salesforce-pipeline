/**************************************************************************************************************************
* Program Name         : NF_IngredientRequestController
* Description          : Controller class for NF_IngredientRequestEmailBody VF Component
* Version              : 1.1
* Modification Log     : 20 Jul,2021.
* Modification Log     : 03 Sep,2021.
*--------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId     Version     Developer          Date           Description
*--------------------------------------------------------------------------------------------------------------------------
*   CB_01          DP-38057      1.1    Chayan Batabyal    20 Jul,2021      Queries the first three case products
                                                                            and their associated VSProducts to
                                                                            get the list of ingredients to be sent
                                                                            to the customer an email with required details.
*   CB_02          DP-47302      1.2    Chayan Batabyal    03 Sep,2021      Display agent's' FirstName instead of FullName
***************************************************************************************************************************/
public class NF_IngredientRequestController {
    public String strLabel = LABEL.NF_INGREDIENT_DETAILS;
    //Id of the case record opened.
    public String currentCaseId {get;set;}

    //Customer's name
    public String customerName {get;set;}

    //Wrapper list that'll have all the details
    public List<ProductsAndIngredients> wrapperList{get;set;}

    //Wrapper class to have the description and the ingredient list
    public class ProductsAndIngredients{
        public String shortDescription{get;set;}
        public String ingredients{get;set;}
    }

    //Fetches the details that needs to be displayed in the email template
    public String fetchIngredientDetails(){
        ProductsAndIngredients ingredientWrapper;
        wrapperList = new List<ProductsAndIngredients>();
        String shortDescriptions = '';

        for(Case_Product__c eachCaseProduct : [
            SELECT Product__r.Name, Product__r.Full_Ingredient_List__c
            FROM Case_Product__c
            WHERE Case__c =: currentCaseId
            ORDER BY CreatedDate
            LIMIT 3
        ]){
            ingredientWrapper = new ProductsAndIngredients();
            ingredientWrapper.shortDescription = eachCaseProduct.Product__r.Name;
            ingredientWrapper.ingredients =
                String.isBlank(eachCaseProduct.Product__r.Full_Ingredient_List__c) ?
                'No ingredients listed for this product' :
                eachCaseProduct.Product__r.Full_Ingredient_List__c.replaceAll('\r\n', '<br/>');
            shortDescriptions += (ingredientWrapper.shortDescription + ', ');
            wrapperList.add(ingredientWrapper);
        }

        return shortDescriptions.removeEnd(', ');
    }

    //Getter method for getting the top section value
    public String getTopSectionValue(){
        return strLabel.subString(0, strLabel.indexOf('[DETAILS]')).replace(
            '[SHORT_DESCRIPTIONS]', fetchIngredientDetails()
        );
    }

    //Getter method for getting the bottom section value
    public String getBottomSectionValue(){
        return (customerName + strLabel.substring(
            strLabel.indexOf('[DETAILS]') + 9
        ).replace('[USERNAME]', UserInfo.getFirstName()));
    }
}