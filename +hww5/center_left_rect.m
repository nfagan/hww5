function r = center_left_rect(sz, screen_rect)

w = sz(1);
h = sz(2);

scr_w = screen_rect(3) - screen_rect(1);
scr_h = screen_rect(4) - screen_rect(2);

scr_cx = screen_rect(1) + scr_w * 0.5;
scr_cy = screen_rect(2) + scr_h * 0.5;

cl_cx = scr_cx - scr_w * 0.25;
cl_cy = scr_cy; % stimulus remains in vertical middle of screen.

x0 = cl_cx - w * 0.5;
x1 = cl_cx + w * 0.5;
y0 = cl_cy - h * 0.5;
y1 = cl_cy + h * 0.5;

r = [ x0, y0, x1, y1 ];

end