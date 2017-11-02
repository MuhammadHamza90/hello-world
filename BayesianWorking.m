%Step 1- No. of Nodes
N = 4; 
%Dag should be of same dimension as no of nodes
dag = zeros(N,N);
%name the no of nodes in topological order
C = 1; S = 2; R = 3; W = 4;

% adjust the adjancecy matrix
dag(C,[R S]) = 1;
dag(R,W) = 1;
dag(S,W)=1;

%Drawing the network
nodeLabels = {'Cloudy', 'Raining', 'Sprinkler', 'Wetgrass'};
bg = biograph(dag, nodeLabels, 'arrowsize', 4);
set(bg.Nodes, 'shape', 'ellipse');
bgInViewer = view(bg);

%Alternative way to initiate dag in LOGICAL manner
dag = false(N,N);
dag(C,[R S]) = true;
dag(R,W) = true;
dag(S,W) = true;
discrete_nodes = 1:N;
%if we have a binary then we should multiply node size ny 2
node_sizes = 2*ones(1,N);
%Bayesian Network
bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes);

onodes = [];
bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes, 'observed', onodes);
bnet = mk_bnet(dag, node_sizes, 'names', {'cloudy','S','R','W'}, 'discrete', 1:4);
C = bnet.names{'cloudy'};

bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.5]);
%To make the CPD proceed as
CPT = zeros(2,2,2);
CPT(1,1,1) = 1.0;
CPT(2,1,1) = 0.1;
CPT(1,2,1) =0.1;
CPT(2,2,1) = 0.01;
CPT(1,1,2) = 0.0;
CPT(2,1,2) = 0.9;
CPT(1,2,2) = 0.9;
CPT(2,2,2) = 0.99;

%Alternative way
CPT1 = reshape([1 0.1 0.1 0.01 0 0.9 0.9 0.99], [2 2 2]);

bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.5]);
bnet.CPD{R} = tabular_CPD(bnet, R, [0.8 0.2 0.2 0.8]);
bnet.CPD{S} = tabular_CPD(bnet, S, [0.5 0.9 0.5 0.1]);
bnet.CPD{W} = tabular_CPD(bnet, W, [1 0.1 0.1 0.01 0 0.9 0.9 0.99]);

%inference(computation) 
engine = jtree_inf_engine(bnet);

evidence = cell(1,N);

%Suppose we want to compute the probability that the sprinker was on given that the grass is wet. 
%The evidence consists of the fact that W=2. All the other nodes are hidden (unobserved).
%% Computing marginal distributions
evidence{W} = 2; 
[engine, loglik] = enter_evidence(engine, evidence);
marg = marginal_nodes(engine, S); %P(S=true|W=true) = 0.4298
marg.T(2)

evidence{R} = 2;
[engine, loglik] = enter_evidence(engine, evidence);
marg = marginal_nodes(engine, S);
p = marg.T(2); %P(S=true|W=true,R=true) = 0.1945 
bar(marg.T)

%Joint Distribution
evidence = cell(1,N);
[engine, ll] = enter_evidence(engine, evidence);
m = marginal_nodes(engine, [S R W]);
%adding the evidence that Rain is true so 
evidence{R} = 2;
[engine, ll] = enter_evidence(engine, evidence);
m = marginal_nodes(engine, [S R W])
m.T
bar(m.T)
