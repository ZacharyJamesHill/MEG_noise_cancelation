x = [0.12,0.167,0.218,0.27,0.32,0.368,0.468,0.57,0.62,0.769,0.894];
y = [0.996,0.995,0.9935,0.991,0.987,0.982,0.972,0.962,0.956,0.917,0.921];
coefs = polyfit(x,y,2);

scatter(x,y)
hold on
xvals = linspace(0,1,100);
plot(xvals, polyval(coefs,xvals))
hold off