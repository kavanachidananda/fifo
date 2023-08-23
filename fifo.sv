virtual class fifo;
  pure virtual function void fifo_read(ref bit [14:0] arr[$]);
	pure virtual function void fifo_write(ref bit [14:0] arr[$]);
  pure virtual function bit fifo_full();
  pure virtual function bit fifo_empty();
endclass
class fifo_imp extends fifo;
  int depth = 16;
 static int count;
  bit rd_en;
  bit wr_en;
  bit[14:0] data_in;
  int data_out;
 
  function void fifo_read( ref bit [14:0] arr[$]);  
	if (fifo_empty() == 0) begin
  	rd_en = 1;
  	arr.pop_front();
  	count--;
	end
  endfunction

  function void fifo_write(ref bit [14:0] arr[$]);
    
	if (fifo_full() == 0) begin
  	wr_en = 1;
  	data_in = $urandom_range(0, 50);
  	arr.push_back(data_in);
      $display("write enabled and the data is: data_in=%0d count %0d", data_in,count);
  	count++;
	end
  endfunction

  function bit fifo_full();
	if (count == depth) begin
  	$display("FIFO IS FULL");
  	return 1;
	end
	else begin
  	return 0;
	end
  endfunction

  function bit fifo_empty();
	if (count == 0) begin
  	$display("FIFO IS EMPTY");
  	return 1;
	end else begin
  	return 0;
	end
  endfunction
endclass

class fifo_peek extends fifo_imp;
  function void fifo_read1(ref bit [15:0] arr_with_crc[$]);
	if (fifo_empty()==0) begin
       data_out=arr_with_crc.pop_front();
  	$display("Peeked data with crc: %0d count %0d",data_out,count);
	end
  endfunction
endclass
module top;
  fifo_imp input_fifo;
  fifo_peek output_fifo;
  bit [15:0] arr_with_crc[$];
  bit [14:0] arr[$];
  initial begin
	input_fifo = new();
	output_fifo=new();
	repeat(16) begin
      if (input_fifo.fifo_full() == 0)
  	input_fifo.fifo_write(arr);//calling write function
	end
	$display("data without crc :%0p",arr);
	crc_function(arr,arr_with_crc);//callling crc function after write operation
    $display("data with crc %0p",arr_with_crc);
	repeat(5) begin
      if (input_fifo.fifo_empty() == 0) begin
   	 input_fifo.fifo_read(arr);
   	 output_fifo.fifo_read1(arr_with_crc);
 	 
      end
	end
	arr_with_crc.delete();
	repeat(5) begin
      if (input_fifo.fifo_full() == 0)
  	input_fifo.fifo_write(arr);//calling write function
	end
	$display("data without crc :%0p",arr);
	crc_function(arr,arr_with_crc);//callling crc function after write operation
    $display("data with crc %0p",arr_with_crc);
  end
endmodule
    function automatic void crc_function( bit[14:0] arr[$],ref bit [15:0] arr_with_crc[$]);
      bit crc;
      foreach(arr[i]) begin
  	crc = ^arr[i]; //calculating the crc of each element in arr
  	arr_with_crc.push_back({crc,arr[i]});//concatenating crc bit with array element and pushing it to an array which is 16 bit wide    
      end
    endfunction
