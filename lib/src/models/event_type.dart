enum EventType {
  pageview('pageview'),
  customEvent('custom_event'),
  performance('performance'),
  outbound('outbound'),
  error('error'),
  buttonClick('button_click'),
  copy('copy'),
  formSubmit('form_submit'),
  inputChange('input_change');

  const EventType(this.value);
  final String value;
}
