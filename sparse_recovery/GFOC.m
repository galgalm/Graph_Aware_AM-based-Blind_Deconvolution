function [Omega,x]=GFOC(y,F,Omega,beta,Nei)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

M=@(S) F(:,S);
Psu=@(S) (M(S).'*M(S))^(-1)*M(S).';
P=@(S) M(S)*(M(S).'*M(S))^(-1)*M(S).';
pre= @(S) y.'*P(S)*y-beta*(length(S));

if size(Omega,1)<size(Omega,2)
    Omega=Omega.';
end

cost_ref=pre(Omega);
for ind_o=1:1:numel(Omega)
    o=Omega(ind_o);
    flag=0; change=[];
    for i=1:1:numel(Nei{o})
      if isempty(intersect(Nei{o}(i),Omega))
      Omega_temp=[setdiff(Omega,o);Nei{o}(i)];
      temp=pre(Omega_temp);
          if temp>cost_ref
          cost_ref=temp; 
          change=[ind_o,Nei{o}(i)]; 
          flag=1;
          end
      end
    end
    if flag==1
        Omega(change(1))=change(2); 
    end
    
end

Omega=sort(Omega,'ascend');
%final result for hat_x
x=zeros(size(F,2),1);
x(Omega)=Psu(Omega)*y;



end

