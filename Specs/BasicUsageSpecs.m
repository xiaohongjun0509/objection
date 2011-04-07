#import "SpecHelper.h"
#import <objc/runtime.h>
#import "Fixtures.h"

SPEC_BEGIN(BasicUsageSpecs)

beforeEach(^{
  ObjectionInjector *injector = [Objection createInjector];
  [Objection setGlobalInjector:injector];
});

it(@"correctly builds a registered object", ^{
  id engine = [[Objection globalInjector] getObject:[Engine class]];
  
  assertThat(engine, isNot(nilValue()));
});

it(@"returns nil for a non-registered object", ^{
  Class newClass = objc_allocateClassPair([NSObject class], "MyFooClass", 0);
  objc_registerClassPair(newClass);
  assertThat([[Objection globalInjector] getObject:newClass], is(nilValue()));
});

it(@"correctly builds and object with dependencies", ^{
  Car *car = [[Objection globalInjector] getObject:[Car class]];
  
  assertThat(car, isNot(nilValue()));
  
  assertThat(car.engine, isNot(nilValue()));
  assertThat(car.engine, is(instanceOf([Engine class])));
  
  assertThat(car.brakes, isNot(nilValue()));
  assertThat(car.brakes, is(instanceOf([Brakes class])));
});

it(@"defaults to returning a new instance", ^{
  id thomas = [[Objection globalInjector] getObject:[Engine class]];
  id gordan = [[Objection globalInjector] getObject:[Engine class]];
  
  assertThat(thomas, isNot(sameInstance(gordan)));
});

it(@"will return the same instance if it is registered as a singleton", ^{
  id carFactory1 = [[Objection globalInjector] getObject:[CarFactory class]];
  id carFactory2 = [[Objection globalInjector] getObject:[CarFactory class]];
  
  assertThat(carFactory1, isNot(nilValue()));
  assertThat(carFactory1, is(sameInstance(carFactory2)));
});

it(@"ensures that singletons are properly registered even if they have not been referenced", ^{
  // Ensure that the class is initialized before attempting to retrieve it.  
  id holder1 = [[Objection globalInjector] getObject:[SingletonItemHolder class]];
  id holder2 = [[Objection globalInjector] getObject:[SingletonItemHolder class]];  
  
  assertThat([holder1 singletonItem], is(sameInstance([holder2 singletonItem])));
});

it(@"will not return the same instance per injector if object is a singleton", ^{
  id carFactory1 = [[Objection globalInjector] getObject:[CarFactory class]];
  id carFactory2 = [[Objection createInjector] getObject:[CarFactory class]];
  assertThat(carFactory1, isNot(sameInstance(carFactory2)));
});

it(@"returns nil if the class is nil", ^{
  assertThat([[Objection globalInjector] getObject:nil], is(nilValue()));
});

it(@"doesn't blow up if a nil class is passed into register", ^{
  [Objection registerClass:nil lifeCycle:ObjectionInstantiationRuleSingleton];
});

it(@"calls awakeFromObjection when an object has been constructed", ^{
  id engine = [[Objection globalInjector] getObject:[Engine class]];
  id car = [[Objection globalInjector] getObject:[Car class]];

  assertThatBool([engine awake], equalToBool(YES));
  assertThatBool([car awake], equalToBool(YES));
});

SPEC_END