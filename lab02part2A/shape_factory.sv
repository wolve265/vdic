virtual class shape;
	
	protected real width;
	protected real height;
	
	function new(real w, real h);
		width = w;
		height = h;
	endfunction : new
	
	pure virtual function real get_area();
	
	pure virtual function void print();
	
endclass : shape

class triangle extends shape;
	
	function new(real w, real h);
		super.new(w, h);
	endfunction : new
	
	function real get_area();
		return width*height/2;
	endfunction : get_area
	
	function void print();
		$display("Triangle w=%g h=%g area=%g", width, height, get_area());
	endfunction : print
	
endclass : triangle

class rectangle extends shape;
	
	function new(real w, real h);
		super.new(w, h);
	endfunction : new
	
	function real get_area();
		return width*height;
	endfunction : get_area
	
	function void print();
		$display("Rectangle w=%g h=%g area=%g", width, height, get_area());
	endfunction : print
	
endclass : rectangle

class square extends rectangle;
	
	function new(real w);
		super.new(w, w);
	endfunction : new
	
	function void print();
		$display("Square w=%g area=%g", width, get_area());
	endfunction : print
	
endclass : square

class shape_reporter #(type T = shape);
	
	protected static T shape_storage[$];
	
	static function void add_shape(T t);
		shape_storage.push_back(t);
	endfunction : add_shape
	
	static function void report_shapes();
		real total_area;
		foreach(shape_storage[i]) begin : report_loop
			shape_storage[i].print();
			total_area += shape_storage[i].get_area();
		end : report_loop
		$display("Total area: %g", total_area);
	endfunction : report_shapes
	
endclass : shape_reporter

class shape_factory;
	
	static function shape make_shape(string shape_type, real w, real h);
		
		rectangle rectangle_h;
		square square_h;
		triangle triangle_h;
		
		case(shape_type)
			
			"rectangle": begin : rectangle
				rectangle_h = new(w, h);
				shape_reporter#(rectangle)::add_shape(rectangle_h);
				return rectangle_h;
			end : rectangle
			
			"square": begin : square
				square_h = new(w);
				shape_reporter#(square)::add_shape(square_h);
				return square_h;
			end : square
			
			"triangle": begin : triangle
				triangle_h = new(w, h);
				shape_reporter#(triangle)::add_shape(triangle_h);
				return triangle_h;
			end : triangle
			
			default: begin : error
				$fatal(1, "No such shape: ", shape_type);
			end : error	
			
		endcase // shape_type
		
	endfunction : make_shape
	
endclass : shape_factory

module top;
	
	initial begin : top_core
		
		shape shape_h;
		rectangle rectangle_h;
		square square_h;
		triangle triangle_h;
		
		int file_d;
		string shape_type;
		real w;
		real h;
		
		file_d = $fopen("lab02part2A_shapes.txt", "r");
		while ($fscanf(file_d, "%s %g %g", shape_type, w, h) == 3) begin : read_file_loop
		
			shape_h = shape_factory::make_shape(shape_type, w, h);
			
		end : read_file_loop
		
		shape_reporter#(rectangle)::report_shapes();
		$display();
		shape_reporter#(square)::report_shapes();
		$display();
		shape_reporter#(triangle)::report_shapes();
		$display();
		
	end : top_core
	
endmodule : top