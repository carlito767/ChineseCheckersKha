// Inspired by: https://gamedev.stackexchange.com/questions/26886/how-to-chain-actions-animations-together-and-delay-their-execution/26887#26887

package gato;

interface Process {
  public var finished:Bool;
  public function update(dt:Float):Void;
}
