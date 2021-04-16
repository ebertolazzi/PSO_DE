a = 0;
b = 10;
n = 7;
x = a:(b-a)/100:b;
y = sin(0.1*x.^2)+0.25*rand(size(x));
y = x.*sin(0.1*x.^2)+0.25*rand(size(x));
min_dx = 0.1;

opt = DE();
%opt = PSO();

model       = test3_model( [a,b], n, x, y, min_dx );
target      = @(X) model.target( X );
target_plot = @(X) model.target_plot( X, opt.getIter() );

%LB = [0,1,4,7,10,-2,-2,-2,-2,-2];
%UB = [0,3,6,9,10, 2, 2, 2, 2, 2];
LB = [a*ones(1,n),-10*ones(1,n)];
UB = [b*ones(1,n), 10*ones(1,n)];
opt.setProblem( target, LB, UB );
opt.setPlotFunction( target_plot, 100 );
%opt.setStrategy( 1 );

opt.setVerbose( false ) ;
opt.setPopolation( 50 );
opt.setMaxIter( 40000 );
opt.setMaxFunEvaluation( 10000000 );

opt.optimize();
res = opt.getBest();

[x,y] = model.get_pars( res );
