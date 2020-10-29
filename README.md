# Lambda-on-Prolog
Prologでラムダ計算。

# Example
### モジュールの使用
```
?- use_module(lambda).
true.
```
### ラムダ式
```
?- Lam = lam([x], x-x). % lam(x, x-x)でもよい
Lam = lam([x], x-x).
```
### lamstep/2 関数適用（ベータ変換、外側優先）
```
?- I = lam(a, a), Lam = lam([x, y], y-x)-I-I, lamstep(Lam, Lam2).
I = lam(a, a),
Lam = lam([x, y], y-x)-lam(a, a)-lam(a, a),
Lam2 = lam([y], y-lam(a, a))-lam(a, a).
```
### lamcall/2 最後まで関数適用（無限ループに注意）
```
?- I = lam(a, a), Lam = lam([x, y], y-x)-I-I, lamcall(Lam, X).
I = X, X = lam(a, a),
Lam = lam([x, y], y-x)-lam(a, a)-lam(a, a).
```
### 変数は一番内部のラムダ式に束縛されているとみなす
```
?- Lam = lam([x], lam([x], x-x)-x), lamstep(Lam-y, X).
Lam = lam([x], lam([x], x-x)-x),
X = lam([x], x-x)-y.
```
### 関数適用オペレータ -/2 の結合順序に注意
```
?- Lam1 = lam([a], (a-a)-a), Lam2 = lam([a], a-(a-a)).
Lam1 = lam([a], a-a-a),
Lam2 = lam([a], a-(a-a)).
```
### n_lam(N, Lam) チャーチ数
```
?- n_lam(0, Zero), n_lam(5, Five).
Zero = lam([f, x], x),
Five = lam([f, x], f-(f-(f-(f-(f-x))))).
```
### n_lam(N, Lam)は逆もOK　※ただし、lam([f, x], _)に限る
```
?- Succ = lam([n], lam([f, x], f-(n-f-x))), n_lam(3, N), lamcall(Succ-N, X), n_lam(Y, X).
Succ = lam([n], lam([f, x], f-(n-f-x))),
N = lam([f, x], f-(f-(f-x))),
X = lam([f, x], f-(f-(f-(f-x)))),
Y = 4.
```
### その他の例1 足し算 （add_lamなどは一部しか用意されていない）
```
?- add_lam(Add), n_lam(3, A), n_lam(4, B), lamcall(Add-A-B, X), n_lam(Res, X).
Add = lam([a, b], lam([f, x], a-f-(b-f-x))),
A = lam([f, x], f-(f-(f-x))),
B = lam([f, x], f-(f-(f-(f-x)))),
X = lam([f, x], f-(f-(f-(f-(f-(f-(f-x))))))),
Res = 7.
```
### その他の例2 不動点演算子による再帰で階上を求める（ソースコード参照）
```
?- fact_lam(Fact), n_lam(5, N), lamcall(Fact-N, X), n_lam(Res, X).
Fact = lam([f], lam([x], f-(x-x))-lam([x], f-(x-x)))-lam([fact, n], lam([x, y, z], x-y-z)-(lam([a], a-lam(..., ...)-lam([...|...], x))-n)-lam([f, x], f-x)-(lam([a, b], lam([f, x], a-(... - ...)-x))-n-(fact-(lam([n, f|...], ... - ... - lam(..., ...)-lam([...], u))-n)))),
N = lam([f, x], f-(f-(f-(f-(f-x))))),
X = lam([f, x], f-(f-(f-(f-(f-(f-(f-(f-(... - ...))))))))),
Res = 120.
```
