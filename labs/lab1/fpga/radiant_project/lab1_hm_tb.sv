module lab1_hm_tb;
    logic [3:0] s;
    logic [2:0] led;
    logic [6:0] seg;
    int         errors = 0;

    lab1_hm #(.blink_max(4)) dut (.s(s), .led(led), .seg(seg));
    
    initial begin
        // XOR Gate Conditions
        #1
        s = 4'b0000;
        #10
        assert (led[0] === 0 && led[1] === 0)
            $display("PASSED s = 0000 at time:%0t", $time);
        else begin
            $display("FAILED s = 0000 at time:%0t", $time);
            errors = errors + 1;
        end

        s = 4'b0001;
        #10
        assert (led[0] === 1 && led[1] === 0)
            $display("PASSED s = 0001 at time:%0t", $time);
        else begin
            $display("FAILED s = 0001 at time:%0t", $time);
            errors = errors + 1;
        end
        s = 4'b0010;
        #10
        assert (led[0] === 1 && led[1] === 0)
            $display("PASSED s = 0010 at time:%0t", $time);
        else begin
            $display("FAILED s = 0010 at time:%0t", $time);
            errors = errors + 1;
        end
        s = 4'b0011;
        #10
        assert (led[0] === 0 && led[1] === 0)
            $display("PASSED s = 0011 at time:%0t", $time);
        else begin
            $display("FAILED s = 0011 at time:%0t", $time);
            errors = errors + 1;
        end

        // AND Gate Condition
        s = 4'b1100;
        #10;
        assert (led[0] === 0 && led[1] === 1)
            $display("PASSED s = 1100 at time:%0t", $time);
        else begin
            $display("FAILED s = 1100 at time:%0t", $time);
            errors = errors + 1;
        end

        // Blinking LED[2]
        #500
        if (errors == 0)
            $display("All tests PASSED!");
        else
            $display("lab1_hm FAILED: %0d errors found", errors);
            $finish;
    end
endmodule