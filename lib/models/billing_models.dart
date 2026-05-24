class LineItem {
  String name; double qty; double price; bool isLabour;
  LineItem({required this.name, this.qty=1, this.price=0, this.isLabour=false});
  double get total => qty*price;
}
class InvoiceDoc {
  String id; String docType; String number; String customer; String address; String email; DateTime date; List<LineItem> items; bool addVat; double vatRate; String notes;
  InvoiceDoc({required this.id, required this.docType, required this.number, required this.customer, required this.address, required this.email, required this.date, required this.items, this.addVat=false, this.vatRate=0.2, this.notes=''});
  double get subtotal => items.fold(0.0,(s,i)=>s+i.total);
  double get vat => addVat? subtotal*vatRate : 0.0;
  double get total => subtotal + vat;
}
