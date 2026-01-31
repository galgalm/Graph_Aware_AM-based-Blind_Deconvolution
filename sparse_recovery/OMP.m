function [hat_Omega,hat_x] = OMP(y,H,trial)

s=trial.signal_sparsity;
[m,n]=size(H);

P=@(x) H(:,x)*(H(:,x).'*H(:,x))^(-1)*H(:,x).';
IP=@(x) eye(m)-P(x);
x_est= @(x) (H(:,x).'*H(:,x))^(-1)*H(:,x).'*y;
obje=@(x,y) sum((P(x)*y).^2); 

%epsilon=trial.graph.size*trial.var_n;  %defining a new condition 
r=y;
hat_Omega=[];
for ind_s=1:1:s
i_ref=0;
ref=-1e5;
    for i=1:1:n
        val=obje(i,r);
        if val>ref
            ref=val;
            i_ref=i;
        end
    end 
hat_Omega=[hat_Omega;i_ref];
r=IP(hat_Omega)*y;
%if (r.'*r)<epsilon
%    break
%end
end
hat_Omega=sort(hat_Omega,'ascend');
hat_x=zeros(n,1);
hat_x(hat_Omega)=x_est(hat_Omega.');

end