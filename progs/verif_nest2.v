Require Import floyd.proofauto.
Require Import progs.nest2.

Instance CompSpecs : compspecs := compspecs_program prog.
Instance CS_legal : compspecs_legal CompSpecs.
Proof. prove_CS_legal. Qed.

Local Open Scope logic.

Definition t_struct_b := Tstruct _b noattr.

Definition get_spec :=
 DECLARE _get
  WITH v : reptype' t_struct_b, p : val
  PRE  [] 
        PROP ()
        LOCAL(gvar _p p)
        SEP(`(data_at Ews t_struct_b (repinj _ v) p))
  POST [ tint ]
         PROP() 
         LOCAL (temp 1%positive (Vint (snd (snd v))))
         SEP (`(data_at Ews t_struct_b (repinj _ v) p)).

Definition update22 (i: int) (v: reptype' t_struct_b) : reptype' t_struct_b :=
   (fst v, (fst (snd v), i)).

Definition set_spec :=
 DECLARE _set
  WITH i : int, v : reptype' t_struct_b, p : val
  PRE  [ _i OF tint ] 
         PROP  ()
         LOCAL (gvar _p p; 
                temp _i (Vint i))
         SEP   (`(data_at Ews t_struct_b (repinj _ v) p))
  POST [ tvoid ]
         PROP() LOCAL()
        SEP(`(data_at Ews t_struct_b (repinj _ (update22 i v)) p)).

Definition Vprog : varspecs := (_p, t_struct_b)::nil.

Definition Gprog : funspecs := 
    get_spec::set_spec::nil.

Lemma body_get:  semax_body Vprog Gprog f_get get_spec.
Proof.
start_function.
name i _i.
simpl in v.
unfold_repinj.
Time forward. (* 5.989 sec  -> 2.6*)
Time forward. (* 11.1118 sec -> 7.5 *)
unfold_repinj.
cancel.
Qed.

Lemma body_set:  semax_body Vprog Gprog f_set set_spec.
Proof.
 start_function.
name i_ _i.
simpl in v.
(*destruct v as [a [b c]]; simpl in *. *)
unfold_repinj.
Time forward. (* 10.17 -> 6.93 sec *)
Time forward. (* 8.77 sec *)
unfold update22. simpl.
unfold_repinj.
cancel.
Qed.  (* approx 28 seconds *)

