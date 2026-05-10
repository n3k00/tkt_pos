class AppString {
  // App title
  static const String title = 'Thein Kha Thu POS';
  static const String releaseLabel = 'Beta 5';
  static const String windowTitle = 'Thein Kha Thu POS Beta 5';

  // Common
  static const String home = 'Home';
  static const String filters = 'Filters';
  static const String noResults = 'No results found.';

  // Reports page
  static const String reports = 'Reports';
  static const String reportTransactionsTitle = 'Report Transaction List';
  static const String totalCount = 'Total Count';
  static const String totalCharges = 'Total Charges';
  static const String statPaymentPending = 'Payment Pending';
  static const String statPaymentPaid = 'Payment Paid';
  static const String statCashAdvance = 'Cash Advance';
  static const String noReportsForDate = 'No reports for';

  // Inventory page
  static const String inventory = 'Inventory';
  static const String addTransaction = 'Add Transaction';
  static const String noDrivers = 'No drivers yet. Tap + to add.';
  static const String driverRoomFee = 'Room Fee';
  static const String driverLaborFee = 'Labor Fee';
  static const String driverDeliveryFee = 'Delivery Fee';
  static const String driverTotalCharges = 'Total Charges';
  static const String driverPaidOutAmount = 'Paid Out Amount';
  static const String driverStatusPaid = 'Paid out';
  static const String driverStatusPending = 'Pending payout';
  static const String filterUnclaimedOnly = 'Unclaimed only';
  static const String driverNoFees = 'No additional fees';
  static const String dialogEditDriver = 'Edit Driver';
  static const String dialogAddDriver = 'Add Driver';
  static const String dialogDriverNameHint = 'Driver name';
  static const String dialogDriverNameRequired = 'Name is required';
  static const String dialogDateLabel = 'Date';
  static const String dialogPickDate = 'Pick Date';
  static const String dialogCancel = 'Cancel';
  static const String dialogSave = 'Save';
  static const String dialogClose = 'Close';
  static const String dialogWarning = 'Warning';
  static const String dialogPhoneRequired = 'Phone is required';
  static const String dialogPhoneOrNumberRequired =
      'Phone or Number is required';
  static const String dialogEditTransaction = 'Edit Transaction';
  static const String dialogAddTransaction = 'Add Transaction';
  static const String dialogTransactionDetails = 'Transaction Details';
  static const String dialogClaimTransaction = 'Claim Transaction';
  static const String dialogDeleteTransaction = 'Delete Transaction?';
  static const String dialogConfirmClaim = 'Confirm Claim';
  static const String dialogDelete = 'Delete';
  static const String dialogCashAdvanceOptional = 'Cash Advance (optional)';
  static const String dialogComment = 'Comment';
  static const String dialogPickedUp = 'Picked up';
  static const String dialogPhoneRequiredMm = 'ဖုန်းနံပါတ် ထည့်ပါ';
  static const String snackbarClaimValidation =
      'Please fill in the required transaction fields.';
  static const String dialogDeleteWarning =
      'This will remove the transaction permanently. This cannot be undone.';

  // Snackbars
  static const String snackbarTitleInfo = 'Info';
  static const String snackbarTitleSuccess = 'Success';
  static const String snackbarTitleWarning = 'Warning';
  static const String snackbarTitleError = 'Error';
  static const String snackbarSavedTitle = 'Saved';
  static const String snackbarPrintTitle = 'Print';
  static const String snackbarBackupCancelled = 'Backup cancelled.';
  static String snackbarBackupSaved(String path) => 'Backup saved: $path';
  static String snackbarBackupFailed(String reason) => 'Backup failed: $reason';
  static String snackbarRestoreFailed(String reason) =>
      'Restore failed: $reason';
  static const String snackbarSlipSaved = 'Slip settings updated in database.';
  static const String snackbarPrintSent = 'Sent to printer.';
  static String snackbarTransactionAddFailed(String reason) =>
      'Failed to add transaction: $reason';
  static String snackbarTransactionUpdateFailed(String reason) =>
      'Failed to update transaction: $reason';

  // Inventory table headers
  static const String colNo = 'No';
  static const String colCustomerName = 'Customer Name';
  static const String colPhone = 'Phone';
  static const String colParcelType = 'Parcel Type';
  static const String colNumber = 'Number';
  static const String colCharges = 'Charges';
  static const String colPaymentStatus = 'Payment Status';
  static const String colCashAdvance = 'Cash Advance';
  static const String colDriver = 'Driver';
  static const String colPickedUp = 'Picked Up';
  static const String colComment = 'Comment';
  static const String colActions = 'Actions';
  static const String colCollectTime = 'Collect Time';

  // Search
  static const String searchLabel = 'Search';
  static const String searchHint = 'Type to filter transactions...';
  static const String searchReportsHint = 'Search reports...';

  // Trip/Home page
  static const String noTripMainRecords = 'No records in Trip Main.';

  // Payment statuses
  static const String paymentPending = 'ငွေတောင်းရန်';
  static const String paymentPaid = 'ငွေရှင်းပြီး';
  static const String paymentPendingLegacy = 'Pending';
  static const String paymentPaidLegacy = 'Paid';
  static const String paymentPaidAltMm = paymentPaid;

  // Zawgyi/PDF output source strings. Keep these as Unicode and convert only
  // at the output boundary where Zawgyi is required.
  static const String paidOutStatusLabel = 'Paid out status';
  static const String paidOutStatusPaidMm = 'ငွေထုတ်ပေးပြီး';
  static const String paidOutStatusPendingMm = 'ငွေထုတ်ရန် ကျန်';
}
