// Verilator testbench
#include <iostream>
#include <verilated.h>
#ifdef VCD
#include "verilated_vcd_c.h"
#define mkstring(x) #x
#define mkstring2(x) mkstring(x)
#define VCD_FILE_STR mkstring2(VCD_FILE)
#endif
#include "Vtop.h"
#include "svdpi.h"
#include "Vtop__Dpi.h"

extern void toggleClock();

Vtop *top;
vluint64_t main_time;
double sc_time_stamp () {     // Called by $time in Verilog
  return main_time;           // converts to double, to match
}
void nextCycle() {
  toggleClock();
  top->eval();
  toggleClock();
  top->eval();
}
void test_write() {
  
    top->write_enable = 1;
    top->addr_rd = 15;
    top->data_rd = 500;
    nextCycle();
    top->write_enable = 0;
    
  
}
int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);   // Remember args
  top = new Vtop;



#ifdef VCD
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  top->trace(tfp, 99);
  tfp->open(VCD_FILE_STR);
#endif

  // set the scope correctly so that we can access the clock in C testbench
  svSetScope(svGetScopeFromName("TOP.top.clkg"));
  top->eval();
  top->write_enable = 0;
  top->data_rd = 0;
  top->addr_rd = 0;
  nextCycle();
  test_write();
  nextCycle();
  while (!Verilated::gotFinish()) {
    toggleClock();
    top->eval();
#ifdef VCD
    tfp->dump(main_time);
#endif
    main_time += 1;
  }
#ifdef VCD
  tfp->close();
#endif
  delete top;
  return 0;
}
