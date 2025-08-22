import 'package:three_forge/src/signal/signal_bindings.dart';

class Signal{
  List<SignalBinding?> _bindings = [];
  bool memorize = false;
  bool _shouldPropagate = true;
  bool active = true;
  List? _prevParams;

  validateListener([listener, fnName]) {
    if (listener is! Function) {
      throw( 'listener is a required param of {$fnName}() and should be a Function.');
    }
  }

  /**
   * @param {Function} listener
   * @param {boolean} isOnce
   * @param {Object} [listenerContext]
   * @param {Number} [priority]
   * @return {SignalBinding}
   * @private
   */
  _registerListener([Function? listener, bool isOnce = false, listenerContext, int priority = 0]) {
    int prevIndex = this._indexOfListener(listener, listenerContext);
    SignalBinding? binding;

    if (prevIndex != -1) {
      binding = this._bindings[prevIndex];
      if (binding?.isOnce != isOnce) {
        throw('You cannot add'+ (isOnce? '' : 'Once') +'() then add'+ (!isOnce? '' : 'Once') +'() the same listener without removing the relationship first.');
      }
    } else {
      binding = new SignalBinding(this, listener, isOnce, listenerContext, priority);
      this._addBinding(binding);
    }

    if(this.memorize && this._prevParams != null){
      binding?.execute(this._prevParams!);
    }

    return binding;
  }

  void _addBinding(SignalBinding binding) {
    //simplified insertion sort
    int n = this._bindings.length;
    do { --n; } while (this._bindings[n] != null && binding.priority <= (this._bindings[n]?.priority ?? 0));
    this._bindings.insert(n+1, binding);//.splice(n + 1, 0, binding);
  }

  /**
   * @param {Function} listener
   * @return {number}
   * @private
   */
  int _indexOfListener([Function? listener, context]) {
    var n = this._bindings.length,
        cur;
    while (n > 0) {
      n--;
      cur = this._bindings[n];
      if (cur._listener == listener && cur.context == context) {
        return n;
      }
    }
    return -1;
  }

  /**
   * Check if listener was attached to Signal.
   * @param {Function} listener
   * @param {Object} [context]
   * @return {boolean} if Signal has the specified listener.
   */
  bool has([Function? listener, context]) {
    return this._indexOfListener(listener, context) != -1;
  }

  /**
   * Add a listener to the signal.
   * @param {Function} listener Signal handler function.
   * @param {Object} [listenerContext] Context on which listener will be executed (object that should represent the `this` variable inside listener function).
   * @param {Number} [priority] The priority level of the event listener. Listeners with higher priority will be executed before listeners with lower priority. Listeners with same priority level will be executed at the same order as they were added. (default = 0)
   * @return {SignalBinding} An Object representing the binding between the Signal and listener.
   */
  add([Function? listener, listenerContext, int priority = 0]) {
    validateListener(listener, 'add');
    return this._registerListener(listener, false, listenerContext, priority);
  }

  /**
   * Add listener to the signal that should be removed after first execution (will be executed only once).
   * @param {Function} listener Signal handler function.
   * @param {Object} [listenerContext] Context on which listener will be executed (object that should represent the `this` variable inside listener function).
   * @param {Number} [priority] The priority level of the event listener. Listeners with higher priority will be executed before listeners with lower priority. Listeners with same priority level will be executed at the same order as they were added. (default = 0)
   * @return {SignalBinding} An Object representing the binding between the Signal and listener.
   */
  addOnce([Function? listener, listenerContext, int priority = 0]) {
    validateListener(listener, 'addOnce');
    return this._registerListener(listener, true, listenerContext, priority);
  }

  /**
   * Remove a single listener from the dispatch queue.
   * @param {Function} listener Handler function that should be removed.
   * @param {Object} [context] Execution context (since you can add the same handler multiple times if executing in a different context).
   * @return {Function} Listener handler function.
   */
  remove([Function? listener, context]) {
    validateListener(listener, 'remove');

    var i = this._indexOfListener(listener, context);
    if (i != -1) {
      this._bindings[i]?.dispose(); //no reason to a SignalBinding exist if it isn't attached to a signal
      this._bindings.removeAt(i);
    }
    return listener;
  }

  /**
   * Remove all listeners from the Signal.
   */
  void removeAll() {
    int n = this._bindings.length;
    while (n > 0) {
      n--;
      this._bindings[n]?.dispose();
    }
    this._bindings.length = 0;
  }

  /**
   * @return {number} Number of listeners attached to the Signal.
   */
  int getNumListeners() {
    return this._bindings.length;
  }

  /**
   * Stop propagation of the event, blocking the dispatch to next listeners on the queue.
   * <p><strong>IMPORTANT:</strong> should be called only during signal dispatch, calling it before/after dispatch won't affect signal broadcast.</p>
   * @see Signal.prototype.disable
   */
  void halt() {
    this._shouldPropagate = false;
  }

  /**
   * Dispatch/Broadcast Signal to all listeners added to the queue.
   * @param {...*} [params] Parameters that should be passed to each handler.
   */
  void dispatch([param]) {
    if (! this.active) {
      return;
    }

    var paramsArr = [];//Array.prototype.slice.call(arguments);
    int n = this._bindings.length;
    List<SignalBinding?> bindings;

    if (this.memorize) {
      this._prevParams = paramsArr;
    }

    if (n == 0) {
      //should come after memorize
      return;
    }

    bindings = this._bindings.sublist(0); //clone array in case add/remove items during dispatch
    this._shouldPropagate = true; //in case `halt` was called before dispatch or during the previous dispatch.

    //execute all callbacks until end of the list or until a callback returns `false` or stops propagation
    //reverse loop since listeners with higher priority will be added at the end of the list
    do { n--; } while (bindings[n] != null&& this._shouldPropagate && bindings[n]?.execute(paramsArr) != false);
  }

  /**
   * Forget memorized arguments.
   * @see Signal.memorize
   */
  void forget(){
    this._prevParams = null;
  }

  /**
   * Remove all bindings from signal and destroy any reference to external objects (destroy Signal object).
   * <p><strong>IMPORTANT:</strong> calling any method on the signal instance after calling dispose will throw errors.</p>
   */
  void dispose() {
    this.removeAll();
    this._bindings.clear();
    this._prevParams?.clear();
  }

  /**
   * @return {string} String representation of the object.
   */
  String toString() {
    return '[Signal active: $active numListeners:${getNumListeners()}]';
  }
}