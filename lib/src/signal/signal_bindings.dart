import 'package:three_forge/src/signal/signal.dart';

class SignalBinding{
  bool active = true;
  List? params;
  Signal? signal;
  bool isOnce;
  int priority;
  dynamic context;
  Function? listener;

  SignalBinding(this.signal, [this.listener, this.isOnce = false, this.context, this.priority = 0]);

  /**
   * Call listener passing arbitrary parameters.
   * <p>If binding was added using `Signal.addOnce()` it will be automatically removed from signal dispatch queue, this method is used internally for the signal dispatch.</p>
   * @param {Array} [paramsArr] Array of parameters that should be passed to the listener
   * @return {*} Value returned by the listener.
   */
  execute(List paramsArr) {
    var handlerReturn, params;
    if (this.active && listener != null) {
      params = this.params != null? (this.params!..addAll(paramsArr)):paramsArr;//?.concat(paramsArr) : paramsArr;
      handlerReturn = Function.apply(listener!,this.context, params);
      if (isOnce) {
        this.detach();
      }
    }
    return handlerReturn;
  }

  /**
   * Detach binding from signal.
   * - alias to: mySignal.remove(myBinding.getListener());
   * @return {Function|null} Handler function bound to the signal or `null` if binding was previously detached.
   */
  detach() {
    return this.isBound()? signal?.remove(listener, this.context) : null;
  }

  /**
   * @return {Boolean} `true` if binding is still bound to the signal and have a listener.
   */
  bool isBound() {
    return (signal != null && listener != null);
  }

  /**
   * Delete instance properties
   * @private
   */
  void dispose() {
    signal?.dispose();
    context = null;
    listener = null;
  }

  /**
   * @return {string} String representation of the object.
   */
  toString() {
    return '[SignalBinding isOnce: $isOnce, isBound: ${isBound()}, active: $active]';
  }
}