function  [hat_Omega,hat_x,count] = BNB_GB(y,H,trial)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Define Parameters
s=trial.signal_sparsity;
 
%D=trial.D;
N=size(H,1);

%useful function and handels
y_cost=y.'*y; 
M=@(S) H(:,S);
Psu=@(S) (M(S).'*M(S))^(-1)*M(S).';
P=@(S) M(S)*(M(S).'*M(S))^(-1)*M(S).';
h.pre= @(S) y.'*P(S)*y-trial.GIC_beta*(length(S));
h.N=N;

% Pre processing: single column computing and ordering
singl.cost=zeros(N,1);
for ind_m=1:1:N
    singl.cost(ind_m)=h.pre(ind_m);    %added beta
end
[singl.cost,singl.ind]=sort(singl.cost,'descend');

h.Ord=singl.ind;
%h.D=D(h.Ord,h.Ord);
h.deg=trial.filter_degree;
h.singl.cost=singl.cost;
% upper and lower bounds handels  
h.bound.l=@(c_cost) c_cost;
h.bound.u=@(c_cost,card,depth) h.bound.l(c_cost)+max((s-card)*singl.cost(depth+1),0); 
h.count=0;

% -------Initialization--------
itr=0;
%first candidate
C.S_out{1}=[];
C.S_in{1}=[];
C.cost(1)=0;
C=FillOut(C,1,h);


[L,ind_opt]=max(C.low);
[U,ind_U]=max(C.up); 

    while true
    [C,h]=NewCandidate(C,ind_U(1),h);
    C=EraseOldCandidate(C,ind_U(1));
    
    [L,ind_opt]=max(C.low);
    [U,~]=max(C.up); 
    
    check=min(C.depth(setdiff(1:length(C.depth),ind_opt )))/h.N;
    if (U-L)/U<0.0001 || (check>0.3 && check<1)
        break
    end
    temp=setdiff(find(C.up<=L),ind_opt);  %new line
    C=EraseOldCandidate(C,temp);  %new line

   AA=setdiff(1:length(C.card),find(C.card==s));
   temp=min(C.depth(AA));
   if temp==h.N
       break
   end
   AA=setdiff(find(C.depth==temp),find(C.card==s));
    [~,ind_U]=max(C.up(AA));
    ind_U=AA(ind_U);
    
   % if (C.card(ind_U)>(s-1))
     %   gal
    %end

  %  if isempty(ind_U)
   %     gal 
 %   end 

 %   if itr==20000
   %     display('gal') 
%    end
   %if isempty(temp)
   %     break; 
   %end

    %[U,b]=max(C.up(temp)); 
    
    % ind_U=temp(b);

    %selection of next rectangle 
  % temp=find(C.card<s);
 %  [junk,ind_L]=min(C.low(temp));        %close to the standard option
%   ind_L=temp(ind_L);
    
    itr=itr+1;
    end
%finalize the algorithm 
hat_Omega=sort(h.Ord(C.S_in{ind_opt(1)}),'ascend');
%final result for hat_x
hat_x=zeros(size(H,2),1);
hat_x(hat_Omega)=Psu(hat_Omega)*y;
%fprintf('GBNB: converged in %d iterations \n',itr)

count=h.count;

end


function C=FillOut(C,ind,h)

C.card(ind)=length(C.S_in{ind});
C.depth(ind)=length(C.S_out{ind})+length(C.S_in{ind});
C.cost(ind)=h.pre(h.Ord(C.S_in{ind}));
C.low(ind)=h.bound.l(C.cost(ind));
if C.depth(ind)==h.N
    C.up(ind)=C.low(ind);
else
C.up(ind)=h.bound.u(C.cost(ind),C.card(ind),C.depth(ind));
end

end


function [C,h]=NewCandidate(C,ind,h)
i_1=length(C.low)+1;
i_2=length(C.low)+2;

%candidate one 
C.S_out{i_1}=[C.S_out{ind}; C.depth(ind)+1];
C.S_in{i_1}=[C.S_in{ind}];
C=FillOut(C,i_1,h);

%candidate one 
C.S_out{i_2}=[C.S_out{ind}];
C.S_in{i_2}=[C.S_in{ind}; C.depth(ind)+1];
C=FillOut(C,i_2,h);

end

function C=EraseOldCandidate(C,ind)

%candidate one 
C.S_out(ind)=[];
C.S_in(ind)=[];
C.card(ind)=[];
C.depth(ind)=[];
C.cost(ind)=[];
C.low(ind)=[];
C.up(ind)=[];
end


