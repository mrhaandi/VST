From Coq Require Import String List ZArith.
From compcert Require Import Coqlib Integers Floats AST Ctypes Cop Clight Clightdefs.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Open Scope string_scope.
Local Open Scope clight_scope.

Module Info.
  Definition version := "3.9".
  Definition build_number := "".
  Definition build_tag := "".
  Definition build_branch := "".
  Definition arch := "x86".
  Definition model := "64".
  Definition abi := "standard".
  Definition bitsize := 64.
  Definition big_endian := false.
  Definition source_file := "progs64/incr.c".
  Definition normalized := true.
End Info.

Definition ___builtin_annot : ident := 17%positive.
Definition ___builtin_annot_intval : ident := 18%positive.
Definition ___builtin_bswap : ident := 2%positive.
Definition ___builtin_bswap16 : ident := 4%positive.
Definition ___builtin_bswap32 : ident := 3%positive.
Definition ___builtin_bswap64 : ident := 1%positive.
Definition ___builtin_clz : ident := 5%positive.
Definition ___builtin_clzl : ident := 6%positive.
Definition ___builtin_clzll : ident := 7%positive.
Definition ___builtin_ctz : ident := 8%positive.
Definition ___builtin_ctzl : ident := 9%positive.
Definition ___builtin_ctzll : ident := 10%positive.
Definition ___builtin_debug : ident := 36%positive.
Definition ___builtin_expect : ident := 25%positive.
Definition ___builtin_fabs : ident := 11%positive.
Definition ___builtin_fabsf : ident := 12%positive.
Definition ___builtin_fmadd : ident := 28%positive.
Definition ___builtin_fmax : ident := 26%positive.
Definition ___builtin_fmin : ident := 27%positive.
Definition ___builtin_fmsub : ident := 29%positive.
Definition ___builtin_fnmadd : ident := 30%positive.
Definition ___builtin_fnmsub : ident := 31%positive.
Definition ___builtin_fsqrt : ident := 13%positive.
Definition ___builtin_membar : ident := 19%positive.
Definition ___builtin_memcpy_aligned : ident := 15%positive.
Definition ___builtin_read16_reversed : ident := 32%positive.
Definition ___builtin_read32_reversed : ident := 33%positive.
Definition ___builtin_sel : ident := 16%positive.
Definition ___builtin_sqrt : ident := 14%positive.
Definition ___builtin_unreachable : ident := 24%positive.
Definition ___builtin_va_arg : ident := 21%positive.
Definition ___builtin_va_copy : ident := 22%positive.
Definition ___builtin_va_end : ident := 23%positive.
Definition ___builtin_va_start : ident := 20%positive.
Definition ___builtin_write16_reversed : ident := 34%positive.
Definition ___builtin_write32_reversed : ident := 35%positive.
Definition ___compcert_i64_dtos : ident := 60%positive.
Definition ___compcert_i64_dtou : ident := 61%positive.
Definition ___compcert_i64_sar : ident := 72%positive.
Definition ___compcert_i64_sdiv : ident := 66%positive.
Definition ___compcert_i64_shl : ident := 70%positive.
Definition ___compcert_i64_shr : ident := 71%positive.
Definition ___compcert_i64_smod : ident := 68%positive.
Definition ___compcert_i64_smulh : ident := 73%positive.
Definition ___compcert_i64_stod : ident := 62%positive.
Definition ___compcert_i64_stof : ident := 64%positive.
Definition ___compcert_i64_udiv : ident := 67%positive.
Definition ___compcert_i64_umod : ident := 69%positive.
Definition ___compcert_i64_umulh : ident := 74%positive.
Definition ___compcert_i64_utod : ident := 63%positive.
Definition ___compcert_i64_utof : ident := 65%positive.
Definition ___compcert_va_composite : ident := 59%positive.
Definition ___compcert_va_float64 : ident := 58%positive.
Definition ___compcert_va_int32 : ident := 56%positive.
Definition ___compcert_va_int64 : ident := 57%positive.
Definition _acquire : ident := 39%positive.
Definition _args : ident := 51%positive.
Definition _ctr : ident := 46%positive.
Definition _ctr_lock : ident := 44%positive.
Definition _freelock : ident := 38%positive.
Definition _freelock2 : ident := 41%positive.
Definition _incr : ident := 49%positive.
Definition _l : ident := 47%positive.
Definition _lockc : ident := 53%positive.
Definition _lockt : ident := 54%positive.
Definition _main : ident := 55%positive.
Definition _makelock : ident := 37%positive.
Definition _read : ident := 50%positive.
Definition _release : ident := 40%positive.
Definition _release2 : ident := 42%positive.
Definition _spawn : ident := 43%positive.
Definition _t : ident := 48%positive.
Definition _thread_func : ident := 52%positive.
Definition _thread_lock : ident := 45%positive.
Definition _t'1 : ident := 75%positive.

Definition v_ctr_lock := {|
  gvar_info := (tarray (tptr tvoid) 2);
  gvar_init := (Init_space 16 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_thread_lock := {|
  gvar_info := (tarray (tptr tvoid) 2);
  gvar_init := (Init_space 16 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ctr := {|
  gvar_info := tuint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_incr := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_l, (tptr (tarray (tptr tvoid) 2))) :: (_t, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _l
    (Eaddrof (Evar _ctr_lock (tarray (tptr tvoid) 2))
      (tptr (tarray (tptr tvoid) 2))))
  (Ssequence
    (Scall None
      (Evar _acquire (Tfunction (Tcons (tptr tvoid) Tnil) tvoid cc_default))
      ((Ecast (Etempvar _l (tptr (tarray (tptr tvoid) 2))) (tptr tvoid)) ::
       nil))
    (Ssequence
      (Sset _t (Evar _ctr tuint))
      (Ssequence
        (Sassign (Evar _ctr tuint)
          (Ebinop Oadd (Etempvar _t tuint) (Econst_int (Int.repr 1) tint)
            tuint))
        (Scall None
          (Evar _release (Tfunction (Tcons (tptr tvoid) Tnil) tvoid
                           cc_default))
          ((Ecast (Etempvar _l (tptr (tarray (tptr tvoid) 2))) (tptr tvoid)) ::
           nil))))))
|}.

Definition f_read := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t, tuint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _acquire (Tfunction (Tcons (tptr tvoid) Tnil) tvoid cc_default))
    ((Ecast
       (Eaddrof (Evar _ctr_lock (tarray (tptr tvoid) 2))
         (tptr (tarray (tptr tvoid) 2))) (tptr tvoid)) :: nil))
  (Ssequence
    (Sset _t (Evar _ctr tuint))
    (Ssequence
      (Scall None
        (Evar _release (Tfunction (Tcons (tptr tvoid) Tnil) tvoid cc_default))
        ((Ecast
           (Eaddrof (Evar _ctr_lock (tarray (tptr tvoid) 2))
             (tptr (tarray (tptr tvoid) 2))) (tptr tvoid)) :: nil))
      (Sreturn (Some (Etempvar _t tuint))))))
|}.

Definition f_thread_func := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_args, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_l, (tptr (tarray (tptr tvoid) 2))) :: nil);
  fn_body :=
(Ssequence
  (Sset _l
    (Eaddrof (Evar _thread_lock (tarray (tptr tvoid) 2))
      (tptr (tarray (tptr tvoid) 2))))
  (Ssequence
    (Scall None (Evar _incr (Tfunction Tnil tvoid cc_default)) nil)
    (Ssequence
      (Scall None
        (Evar _release2 (Tfunction (Tcons (tptr tvoid) Tnil) tvoid
                          cc_default))
        ((Ecast (Etempvar _l (tptr (tarray (tptr tvoid) 2))) (tptr tvoid)) ::
         nil))
      (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))))
|}.

Definition f_main := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_lockc, (tptr (tarray (tptr tvoid) 2))) ::
               (_lockt, (tptr (tarray (tptr tvoid) 2))) :: (_t, tuint) ::
               (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sassign (Evar _ctr tuint) (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sset _lockc
        (Eaddrof (Evar _ctr_lock (tarray (tptr tvoid) 2))
          (tptr (tarray (tptr tvoid) 2))))
      (Ssequence
        (Sset _lockt
          (Eaddrof (Evar _thread_lock (tarray (tptr tvoid) 2))
            (tptr (tarray (tptr tvoid) 2))))
        (Ssequence
          (Scall None
            (Evar _makelock (Tfunction (Tcons (tptr tvoid) Tnil) tvoid
                              cc_default))
            ((Ecast (Etempvar _lockc (tptr (tarray (tptr tvoid) 2)))
               (tptr tvoid)) :: nil))
          (Ssequence
            (Scall None
              (Evar _release (Tfunction (Tcons (tptr tvoid) Tnil) tvoid
                               cc_default))
              ((Ecast (Etempvar _lockc (tptr (tarray (tptr tvoid) 2)))
                 (tptr tvoid)) :: nil))
            (Ssequence
              (Scall None
                (Evar _makelock (Tfunction (Tcons (tptr tvoid) Tnil) tvoid
                                  cc_default))
                ((Ecast (Etempvar _lockt (tptr (tarray (tptr tvoid) 2)))
                   (tptr tvoid)) :: nil))
              (Ssequence
                (Scall None
                  (Evar _spawn (Tfunction
                                 (Tcons
                                   (tptr (Tfunction (Tcons (tptr tvoid) Tnil)
                                           (tptr tvoid) cc_default))
                                   (Tcons (tptr tvoid) Tnil)) tvoid
                                 cc_default))
                  ((Ecast
                     (Eaddrof
                       (Evar _thread_func (Tfunction
                                            (Tcons (tptr tvoid) Tnil)
                                            (tptr tvoid) cc_default))
                       (tptr (Tfunction (Tcons (tptr tvoid) Tnil)
                               (tptr tvoid) cc_default))) (tptr tvoid)) ::
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                   nil))
                (Ssequence
                  (Scall None (Evar _incr (Tfunction Tnil tvoid cc_default))
                    nil)
                  (Ssequence
                    (Scall None
                      (Evar _acquire (Tfunction (Tcons (tptr tvoid) Tnil)
                                       tvoid cc_default))
                      ((Ecast
                         (Etempvar _lockt (tptr (tarray (tptr tvoid) 2)))
                         (tptr tvoid)) :: nil))
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'1)
                          (Evar _read (Tfunction Tnil tuint cc_default)) nil)
                        (Sset _t (Etempvar _t'1 tuint)))
                      (Ssequence
                        (Scall None
                          (Evar _acquire (Tfunction (Tcons (tptr tvoid) Tnil)
                                           tvoid cc_default))
                          ((Ecast
                             (Etempvar _lockc (tptr (tarray (tptr tvoid) 2)))
                             (tptr tvoid)) :: nil))
                        (Ssequence
                          (Scall None
                            (Evar _freelock2 (Tfunction
                                               (Tcons (tptr tvoid) Tnil)
                                               tvoid cc_default))
                            ((Ecast
                               (Etempvar _lockt (tptr (tarray (tptr tvoid) 2)))
                               (tptr tvoid)) :: nil))
                          (Ssequence
                            (Scall None
                              (Evar _freelock (Tfunction
                                                (Tcons (tptr tvoid) Tnil)
                                                tvoid cc_default))
                              ((Ecast
                                 (Etempvar _lockc (tptr (tarray (tptr tvoid) 2)))
                                 (tptr tvoid)) :: nil))
                            (Sreturn (Some (Etempvar _t tuint))))))))))))))))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition composites : list composite_definition :=
nil.

Definition global_definitions : list (ident * globdef fundef type) :=
((___compcert_va_int32,
   Gfun(External (EF_runtime "__compcert_va_int32"
                   (mksignature (AST.Tlong :: nil) AST.Tint cc_default))
     (Tcons (tptr tvoid) Tnil) tuint cc_default)) ::
 (___compcert_va_int64,
   Gfun(External (EF_runtime "__compcert_va_int64"
                   (mksignature (AST.Tlong :: nil) AST.Tlong cc_default))
     (Tcons (tptr tvoid) Tnil) tulong cc_default)) ::
 (___compcert_va_float64,
   Gfun(External (EF_runtime "__compcert_va_float64"
                   (mksignature (AST.Tlong :: nil) AST.Tfloat cc_default))
     (Tcons (tptr tvoid) Tnil) tdouble cc_default)) ::
 (___compcert_va_composite,
   Gfun(External (EF_runtime "__compcert_va_composite"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons (tptr tvoid) (Tcons tulong Tnil))
     (tptr tvoid) cc_default)) ::
 (___compcert_i64_dtos,
   Gfun(External (EF_runtime "__compcert_i64_dtos"
                   (mksignature (AST.Tfloat :: nil) AST.Tlong cc_default))
     (Tcons tdouble Tnil) tlong cc_default)) ::
 (___compcert_i64_dtou,
   Gfun(External (EF_runtime "__compcert_i64_dtou"
                   (mksignature (AST.Tfloat :: nil) AST.Tlong cc_default))
     (Tcons tdouble Tnil) tulong cc_default)) ::
 (___compcert_i64_stod,
   Gfun(External (EF_runtime "__compcert_i64_stod"
                   (mksignature (AST.Tlong :: nil) AST.Tfloat cc_default))
     (Tcons tlong Tnil) tdouble cc_default)) ::
 (___compcert_i64_utod,
   Gfun(External (EF_runtime "__compcert_i64_utod"
                   (mksignature (AST.Tlong :: nil) AST.Tfloat cc_default))
     (Tcons tulong Tnil) tdouble cc_default)) ::
 (___compcert_i64_stof,
   Gfun(External (EF_runtime "__compcert_i64_stof"
                   (mksignature (AST.Tlong :: nil) AST.Tsingle cc_default))
     (Tcons tlong Tnil) tfloat cc_default)) ::
 (___compcert_i64_utof,
   Gfun(External (EF_runtime "__compcert_i64_utof"
                   (mksignature (AST.Tlong :: nil) AST.Tsingle cc_default))
     (Tcons tulong Tnil) tfloat cc_default)) ::
 (___compcert_i64_sdiv,
   Gfun(External (EF_runtime "__compcert_i64_sdiv"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tlong (Tcons tlong Tnil)) tlong
     cc_default)) ::
 (___compcert_i64_udiv,
   Gfun(External (EF_runtime "__compcert_i64_udiv"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tulong (Tcons tulong Tnil)) tulong
     cc_default)) ::
 (___compcert_i64_smod,
   Gfun(External (EF_runtime "__compcert_i64_smod"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tlong (Tcons tlong Tnil)) tlong
     cc_default)) ::
 (___compcert_i64_umod,
   Gfun(External (EF_runtime "__compcert_i64_umod"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tulong (Tcons tulong Tnil)) tulong
     cc_default)) ::
 (___compcert_i64_shl,
   Gfun(External (EF_runtime "__compcert_i64_shl"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tlong
                     cc_default)) (Tcons tlong (Tcons tint Tnil)) tlong
     cc_default)) ::
 (___compcert_i64_shr,
   Gfun(External (EF_runtime "__compcert_i64_shr"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tlong
                     cc_default)) (Tcons tulong (Tcons tint Tnil)) tulong
     cc_default)) ::
 (___compcert_i64_sar,
   Gfun(External (EF_runtime "__compcert_i64_sar"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tlong
                     cc_default)) (Tcons tlong (Tcons tint Tnil)) tlong
     cc_default)) ::
 (___compcert_i64_smulh,
   Gfun(External (EF_runtime "__compcert_i64_smulh"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tlong (Tcons tlong Tnil)) tlong
     cc_default)) ::
 (___compcert_i64_umulh,
   Gfun(External (EF_runtime "__compcert_i64_umulh"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tulong (Tcons tulong Tnil)) tulong
     cc_default)) ::
 (___builtin_bswap64,
   Gfun(External (EF_builtin "__builtin_bswap64"
                   (mksignature (AST.Tlong :: nil) AST.Tlong cc_default))
     (Tcons tulong Tnil) tulong cc_default)) ::
 (___builtin_bswap,
   Gfun(External (EF_builtin "__builtin_bswap"
                   (mksignature (AST.Tint :: nil) AST.Tint cc_default))
     (Tcons tuint Tnil) tuint cc_default)) ::
 (___builtin_bswap32,
   Gfun(External (EF_builtin "__builtin_bswap32"
                   (mksignature (AST.Tint :: nil) AST.Tint cc_default))
     (Tcons tuint Tnil) tuint cc_default)) ::
 (___builtin_bswap16,
   Gfun(External (EF_builtin "__builtin_bswap16"
                   (mksignature (AST.Tint :: nil) AST.Tint16unsigned
                     cc_default)) (Tcons tushort Tnil) tushort cc_default)) ::
 (___builtin_clz,
   Gfun(External (EF_builtin "__builtin_clz"
                   (mksignature (AST.Tint :: nil) AST.Tint cc_default))
     (Tcons tuint Tnil) tint cc_default)) ::
 (___builtin_clzl,
   Gfun(External (EF_builtin "__builtin_clzl"
                   (mksignature (AST.Tlong :: nil) AST.Tint cc_default))
     (Tcons tulong Tnil) tint cc_default)) ::
 (___builtin_clzll,
   Gfun(External (EF_builtin "__builtin_clzll"
                   (mksignature (AST.Tlong :: nil) AST.Tint cc_default))
     (Tcons tulong Tnil) tint cc_default)) ::
 (___builtin_ctz,
   Gfun(External (EF_builtin "__builtin_ctz"
                   (mksignature (AST.Tint :: nil) AST.Tint cc_default))
     (Tcons tuint Tnil) tint cc_default)) ::
 (___builtin_ctzl,
   Gfun(External (EF_builtin "__builtin_ctzl"
                   (mksignature (AST.Tlong :: nil) AST.Tint cc_default))
     (Tcons tulong Tnil) tint cc_default)) ::
 (___builtin_ctzll,
   Gfun(External (EF_builtin "__builtin_ctzll"
                   (mksignature (AST.Tlong :: nil) AST.Tint cc_default))
     (Tcons tulong Tnil) tint cc_default)) ::
 (___builtin_fabs,
   Gfun(External (EF_builtin "__builtin_fabs"
                   (mksignature (AST.Tfloat :: nil) AST.Tfloat cc_default))
     (Tcons tdouble Tnil) tdouble cc_default)) ::
 (___builtin_fabsf,
   Gfun(External (EF_builtin "__builtin_fabsf"
                   (mksignature (AST.Tsingle :: nil) AST.Tsingle cc_default))
     (Tcons tfloat Tnil) tfloat cc_default)) ::
 (___builtin_fsqrt,
   Gfun(External (EF_builtin "__builtin_fsqrt"
                   (mksignature (AST.Tfloat :: nil) AST.Tfloat cc_default))
     (Tcons tdouble Tnil) tdouble cc_default)) ::
 (___builtin_sqrt,
   Gfun(External (EF_builtin "__builtin_sqrt"
                   (mksignature (AST.Tfloat :: nil) AST.Tfloat cc_default))
     (Tcons tdouble Tnil) tdouble cc_default)) ::
 (___builtin_memcpy_aligned,
   Gfun(External (EF_builtin "__builtin_memcpy_aligned"
                   (mksignature
                     (AST.Tlong :: AST.Tlong :: AST.Tlong :: AST.Tlong ::
                      nil) AST.Tvoid cc_default))
     (Tcons (tptr tvoid)
       (Tcons (tptr tvoid) (Tcons tulong (Tcons tulong Tnil)))) tvoid
     cc_default)) ::
 (___builtin_sel,
   Gfun(External (EF_builtin "__builtin_sel"
                   (mksignature (AST.Tint :: nil) AST.Tvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     (Tcons tbool Tnil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (___builtin_annot,
   Gfun(External (EF_builtin "__builtin_annot"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     (Tcons (tptr tschar) Tnil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (___builtin_annot_intval,
   Gfun(External (EF_builtin "__builtin_annot_intval"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tint
                     cc_default)) (Tcons (tptr tschar) (Tcons tint Tnil))
     tint cc_default)) ::
 (___builtin_membar,
   Gfun(External (EF_builtin "__builtin_membar"
                   (mksignature nil AST.Tvoid cc_default)) Tnil tvoid
     cc_default)) ::
 (___builtin_va_start,
   Gfun(External (EF_builtin "__builtin_va_start"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid cc_default))
     (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (___builtin_va_arg,
   Gfun(External (EF_builtin "__builtin_va_arg"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tvoid
                     cc_default)) (Tcons (tptr tvoid) (Tcons tuint Tnil))
     tvoid cc_default)) ::
 (___builtin_va_copy,
   Gfun(External (EF_builtin "__builtin_va_copy"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tvoid
                     cc_default))
     (Tcons (tptr tvoid) (Tcons (tptr tvoid) Tnil)) tvoid cc_default)) ::
 (___builtin_va_end,
   Gfun(External (EF_builtin "__builtin_va_end"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid cc_default))
     (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (___builtin_unreachable,
   Gfun(External (EF_builtin "__builtin_unreachable"
                   (mksignature nil AST.Tvoid cc_default)) Tnil tvoid
     cc_default)) ::
 (___builtin_expect,
   Gfun(External (EF_builtin "__builtin_expect"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tlong (Tcons tlong Tnil)) tlong
     cc_default)) ::
 (___builtin_fmax,
   Gfun(External (EF_builtin "__builtin_fmax"
                   (mksignature (AST.Tfloat :: AST.Tfloat :: nil) AST.Tfloat
                     cc_default)) (Tcons tdouble (Tcons tdouble Tnil))
     tdouble cc_default)) ::
 (___builtin_fmin,
   Gfun(External (EF_builtin "__builtin_fmin"
                   (mksignature (AST.Tfloat :: AST.Tfloat :: nil) AST.Tfloat
                     cc_default)) (Tcons tdouble (Tcons tdouble Tnil))
     tdouble cc_default)) ::
 (___builtin_fmadd,
   Gfun(External (EF_builtin "__builtin_fmadd"
                   (mksignature
                     (AST.Tfloat :: AST.Tfloat :: AST.Tfloat :: nil)
                     AST.Tfloat cc_default))
     (Tcons tdouble (Tcons tdouble (Tcons tdouble Tnil))) tdouble
     cc_default)) ::
 (___builtin_fmsub,
   Gfun(External (EF_builtin "__builtin_fmsub"
                   (mksignature
                     (AST.Tfloat :: AST.Tfloat :: AST.Tfloat :: nil)
                     AST.Tfloat cc_default))
     (Tcons tdouble (Tcons tdouble (Tcons tdouble Tnil))) tdouble
     cc_default)) ::
 (___builtin_fnmadd,
   Gfun(External (EF_builtin "__builtin_fnmadd"
                   (mksignature
                     (AST.Tfloat :: AST.Tfloat :: AST.Tfloat :: nil)
                     AST.Tfloat cc_default))
     (Tcons tdouble (Tcons tdouble (Tcons tdouble Tnil))) tdouble
     cc_default)) ::
 (___builtin_fnmsub,
   Gfun(External (EF_builtin "__builtin_fnmsub"
                   (mksignature
                     (AST.Tfloat :: AST.Tfloat :: AST.Tfloat :: nil)
                     AST.Tfloat cc_default))
     (Tcons tdouble (Tcons tdouble (Tcons tdouble Tnil))) tdouble
     cc_default)) ::
 (___builtin_read16_reversed,
   Gfun(External (EF_builtin "__builtin_read16_reversed"
                   (mksignature (AST.Tlong :: nil) AST.Tint16unsigned
                     cc_default)) (Tcons (tptr tushort) Tnil) tushort
     cc_default)) ::
 (___builtin_read32_reversed,
   Gfun(External (EF_builtin "__builtin_read32_reversed"
                   (mksignature (AST.Tlong :: nil) AST.Tint cc_default))
     (Tcons (tptr tuint) Tnil) tuint cc_default)) ::
 (___builtin_write16_reversed,
   Gfun(External (EF_builtin "__builtin_write16_reversed"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tvoid
                     cc_default)) (Tcons (tptr tushort) (Tcons tushort Tnil))
     tvoid cc_default)) ::
 (___builtin_write32_reversed,
   Gfun(External (EF_builtin "__builtin_write32_reversed"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tvoid
                     cc_default)) (Tcons (tptr tuint) (Tcons tuint Tnil))
     tvoid cc_default)) ::
 (___builtin_debug,
   Gfun(External (EF_external "__builtin_debug"
                   (mksignature (AST.Tint :: nil) AST.Tvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     (Tcons tint Tnil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (_makelock,
   Gfun(External (EF_external "makelock"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid cc_default))
     (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (_freelock,
   Gfun(External (EF_external "freelock"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid cc_default))
     (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (_acquire,
   Gfun(External (EF_external "acquire"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid cc_default))
     (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (_release,
   Gfun(External (EF_external "release"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid cc_default))
     (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (_freelock2,
   Gfun(External (EF_external "freelock2"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid cc_default))
     (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (_release2,
   Gfun(External (EF_external "release2"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid cc_default))
     (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (_spawn,
   Gfun(External (EF_external "spawn"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tvoid
                     cc_default))
     (Tcons
       (tptr (Tfunction (Tcons (tptr tvoid) Tnil) (tptr tvoid) cc_default))
       (Tcons (tptr tvoid) Tnil)) tvoid cc_default)) ::
 (_ctr_lock, Gvar v_ctr_lock) :: (_thread_lock, Gvar v_thread_lock) ::
 (_ctr, Gvar v_ctr) :: (_incr, Gfun(Internal f_incr)) ::
 (_read, Gfun(Internal f_read)) ::
 (_thread_func, Gfun(Internal f_thread_func)) ::
 (_main, Gfun(Internal f_main)) :: nil).

Definition public_idents : list ident :=
(_main :: _thread_func :: _read :: _incr :: _ctr :: _thread_lock ::
 _ctr_lock :: _spawn :: _release2 :: _freelock2 :: _release :: _acquire ::
 _freelock :: _makelock :: ___builtin_debug :: ___builtin_write32_reversed ::
 ___builtin_write16_reversed :: ___builtin_read32_reversed ::
 ___builtin_read16_reversed :: ___builtin_fnmsub :: ___builtin_fnmadd ::
 ___builtin_fmsub :: ___builtin_fmadd :: ___builtin_fmin ::
 ___builtin_fmax :: ___builtin_expect :: ___builtin_unreachable ::
 ___builtin_va_end :: ___builtin_va_copy :: ___builtin_va_arg ::
 ___builtin_va_start :: ___builtin_membar :: ___builtin_annot_intval ::
 ___builtin_annot :: ___builtin_sel :: ___builtin_memcpy_aligned ::
 ___builtin_sqrt :: ___builtin_fsqrt :: ___builtin_fabsf ::
 ___builtin_fabs :: ___builtin_ctzll :: ___builtin_ctzl :: ___builtin_ctz ::
 ___builtin_clzll :: ___builtin_clzl :: ___builtin_clz ::
 ___builtin_bswap16 :: ___builtin_bswap32 :: ___builtin_bswap ::
 ___builtin_bswap64 :: ___compcert_i64_umulh :: ___compcert_i64_smulh ::
 ___compcert_i64_sar :: ___compcert_i64_shr :: ___compcert_i64_shl ::
 ___compcert_i64_umod :: ___compcert_i64_smod :: ___compcert_i64_udiv ::
 ___compcert_i64_sdiv :: ___compcert_i64_utof :: ___compcert_i64_stof ::
 ___compcert_i64_utod :: ___compcert_i64_stod :: ___compcert_i64_dtou ::
 ___compcert_i64_dtos :: ___compcert_va_composite ::
 ___compcert_va_float64 :: ___compcert_va_int64 :: ___compcert_va_int32 ::
 nil).

Definition prog : Clight.program := 
  mkprogram composites global_definitions public_idents _main Logic.I.


