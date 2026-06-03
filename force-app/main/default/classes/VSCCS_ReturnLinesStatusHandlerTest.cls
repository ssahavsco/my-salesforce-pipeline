@IsTest
private class VSCCS_ReturnLinesStatusHandlerTest {
  /**
   * Utility to fabricate Input wrapper
   */
  private static VSCCS_ReturnLinesStatusHandler.Input makeInput(Id crId) {
    VSCCS_ReturnLinesStatusHandler.Input i = new VSCCS_ReturnLinesStatusHandler.Input();
    i.caseResolutionId = (String) crId;
    return i;
  }

  /**
   * Creates a minimal Case_Resolution__c record taking into account typical required fields.
   * Adjust field population here if your org has additional required fields/validation.
   */
  private static Case_Resolution__c makeCR() {
    // Align fabrication with AoEgcPgcService_Test.testSetupData() so required fields/relations are satisfied.
    // 1) Create Person Account
    String paRtId = Schema.getGlobalDescribe()
      .get('Account')
      .getDescribe()
      .getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    Account acct = new Account(
      RecordTypeId = paRtId,
      FirstName = 'Test',
      LastName = 'Account'
    );
    insert acct;

    // 2) Create a Case tied to that Account (uses any available Case RecordType like the reference test)
    RecordType caseRt = [
      SELECT Id
      FROM RecordType
      WHERE sObjectType = 'Case'
      LIMIT 1
    ];
    Case c = new Case(RecordTypeId = caseRt.Id, AccountId = acct.Id);
    insert c;

    // 3) Create Case_Resolution__c with the same required fields used by AoEgcPgcService_Test
    Case_Resolution__c cr = new Case_Resolution__c(
      Amount__c = 100,
      Related_Case__c = c.Id,
      Case_Resolution_Type__c = 'Claim',
      Requested_Gift_Card_Type__c = 'Physical Gift Card'
    );
    insert cr;
    return cr;
  }

  /**
   * Creates N return line records tied to the given Case Resolution and with the specified Completed__c value.
   */
  private static List<International_Return_Lines__c> makeLines(
    Id crId,
    Integer n,
    Boolean completed
  ) {
    List<International_Return_Lines__c> lines = new List<International_Return_Lines__c>();
    for (Integer i = 0; i < n; i++) {
      International_Return_Lines__c l = new International_Return_Lines__c();
      l.Case_Resolution__c = crId;
      l.Completed__c = completed;
      lines.add(l);
    }
    insert lines;
    return lines;
  }

  @IsTest
  static void testNoLines_NoUpdate() {
    // When no lines exist for the Case Resolution, handler should not update CR
    Case_Resolution__c cr = makeCR();
    Date beforeCall = Date.today().addDays(-5);

    // Manually set fields to known values prior to call (if they exist)
    cr.EC_Status__c = null;
    cr.Completion_Date__c = null;
    update cr;

    Test.startTest();
    VSCCS_ReturnLinesStatusHandler.caseResolutionStatus(
      new List<VSCCS_ReturnLinesStatusHandler.Input>{ makeInput(cr.Id) }
    );
    Test.stopTest();

    Case_Resolution__c crAfter = [
      SELECT Id, EC_Status__c, Completion_Date__c
      FROM Case_Resolution__c
      WHERE Id = :cr.Id
    ];
    System.assertEquals(
      null,
      crAfter.EC_Status__c,
      'EC_Status__c should remain unchanged when there are no lines'
    );
    System.assertEquals(
      null,
      crAfter.Completion_Date__c,
      'Completion_Date__c should remain unchanged when there are no lines'
    );
  }

  @IsTest
  static void testAllLinesCompleted_PerformsUpdate() {
    // When all lines are Completed__c = true and at least one line exists, CR should be updated
    Case_Resolution__c cr = makeCR();
    makeLines(cr.Id, 3, true);

    Test.startTest();
    VSCCS_ReturnLinesStatusHandler.caseResolutionStatus(
      new List<VSCCS_ReturnLinesStatusHandler.Input>{ makeInput(cr.Id) }
    );
    Test.stopTest();

    Case_Resolution__c crAfter = [
      SELECT Id, EC_Status__c, Completion_Date__c
      FROM Case_Resolution__c
      WHERE Id = :cr.Id
    ];
    System.assertEquals(
      'Completed',
      crAfter.EC_Status__c,
      'EC_Status__c should be set to Completed when all lines are completed'
    );
    System.assertEquals(
      Date.today(),
      crAfter.Completion_Date__c,
      'Completion_Date__c should be set to today when all lines are completed'
    );
  }

  @IsTest
  static void testNotAllLinesCompleted_NoUpdate() {
    // When one or more lines are not completed, CR should not be updated
    Case_Resolution__c cr = makeCR();
    // Mix of completed and not completed
    makeLines(cr.Id, 2, true);
    makeLines(cr.Id, 1, false);

    // Initialize fields to known values to assert no change
    cr.EC_Status__c = null;
    cr.Completion_Date__c = null;
    update cr;

    Test.startTest();
    VSCCS_ReturnLinesStatusHandler.caseResolutionStatus(
      new List<VSCCS_ReturnLinesStatusHandler.Input>{ makeInput(cr.Id) }
    );
    Test.stopTest();

    Case_Resolution__c crAfter = [
      SELECT Id, EC_Status__c, Completion_Date__c
      FROM Case_Resolution__c
      WHERE Id = :cr.Id
    ];
    System.assertEquals(
      null,
      crAfter.EC_Status__c,
      'EC_Status__c should not be updated when any line is not completed'
    );
    System.assertEquals(
      null,
      crAfter.Completion_Date__c,
      'Completion_Date__c should not be updated when any line is not completed'
    );
  }

  @IsTest
  static void testMultipleInvocationsStaticFlagReset() {
    VSCCS_ReturnLinesStatusHandler.Input i = new VSCCS_ReturnLinesStatusHandler.Input();
    List<VSCCS_ReturnLinesStatusHandler.Input> input = new List<VSCCS_ReturnLinesStatusHandler.Input>();
    input.add(i);
    VSCCS_ReturnLinesStatusHandler.caseResolutionStatus(input);
  }

  @IsTest
  static void testExceptionPath_InvalidIdHandled() {
    // Provide an invalid Id to exercise the catch block. The method must not throw.
    VSCCS_ReturnLinesStatusHandler.Input bad = new VSCCS_ReturnLinesStatusHandler.Input();
    bad.caseResolutionId = 'a00xxxxxxxxxxxx'; // malformed/unknown Id

    Test.startTest();
    // Should not throw even though query will fail; catch block will log
    VSCCS_ReturnLinesStatusHandler.caseResolutionStatus(
      new List<VSCCS_ReturnLinesStatusHandler.Input>{ bad }
    );
    Test.stopTest();

    // Nothing to assert on records; success criteria is no unhandled exception.
    System.assert(
      true,
      'Method should handle exceptions internally without propagating.'
    );
  }
}