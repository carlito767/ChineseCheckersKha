class Signal<T> {
  var slots:Array<T>;

  public function new() {
    slots = [];
  }

  public function connect(slot:T) {
    slots.push(slot);
  }

  public function disconnect(?slot:T) {
    if (slot == null) {
      slots = [];
      return;
    }

    var i = 0;
    while (i < slots.length) {
      if (Reflect.compareMethods(slots[i], slot)) {
        slots.splice(i, 1);
      }
      else {
        ++i;
      }
    }
  }
}

class Signal0 extends Signal<Void->Void> {
  public function emit() {
    for (slot in slots) {
      slot();
    }
  }
}

class Signal1<T> extends Signal<T->Void> {
  public function emit(p:T) {
    for (slot in slots) {
      slot(p);
    }
  }
}

class Signal2<T1, T2> extends Signal<T1->T2->Void> {
  public function emit(p1:T1, p2:T2) {
    for (slot in slots) {
      slot(p1, p2);
    }
  }
}
