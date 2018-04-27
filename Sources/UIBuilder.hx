import haxe.macro.Context;
import haxe.macro.Expr;

class UIBuilder {
  static public function build():Array<Field> {
    var fields = Context.getBuildFields();

    for (field in fields) {
      if (field.meta != null) {
        for (entry in field.meta) {
          if (entry.name == 'ui') {
            switch field.kind {
            case FFun(f):
              if (f.args.length > 0 && f.args[0].name == 'object') {
                field.access = [APublic];
                f.expr = macro {
                  scaleObject(object);
                  var eval:MuiEval = evaluate(object);
                  ${f.expr};
                  if (showHitbox) {
                    g.color = Color.Green;
                    g.drawRect(object.x, object.y, object.w, object.h);
                  }
                  return eval;
                }
              }
              else {
                Context.error('Function should have first parameter named "object"', field.pos);
              }
            case _:
            }
          }
        }
      }
    }

    return fields;
  }
}
