{-# LANGUAGE UnicodeSyntax, NoImplicitPrelude, FlexibleContexts #-}

{- |
Module      :  Control.Concurrent.MVar.Lifted
Copyright   :  Bas van Dijk
License     :  BSD-style

Maintainer  :  Bas van Dijk <v.dijk.bas@gmail.com>
Stability   :  experimental

This is a wrapped version of 'Control.Concurrent.MVar' with types generalized
from @IO@ to all monads in either 'MonadBase' or 'MonadBaseControl'.
-}

module Control.Concurrent.MVar.Lifted
    ( MVar.MVar
    , newEmptyMVar
    , newMVar
    , takeMVar
    , putMVar
    , readMVar
    , swapMVar
    , tryTakeMVar
    , tryPutMVar
    , isEmptyMVar
    , withMVar
    , modifyMVar_
    , modifyMVar
    , addMVarFinalizer
    ) where


--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

-- from base:
import Data.Bool     ( Bool )
import Data.Function ( ($) )
import Data.Maybe    ( Maybe )
import Control.Monad ( return )
import System.IO     ( IO )
import           Control.Concurrent.MVar  ( MVar )
import qualified Control.Concurrent.MVar as MVar

-- from base-unicode-symbols:
import Data.Function.Unicode ( (∘) )

-- from transformers-base:
import Control.Monad.Base ( MonadBase, liftBase )

-- from monad-control:
import Control.Monad.Trans.Control ( MonadBaseControl, liftBaseOp, liftBaseDiscard )

-- from lifted-base (this package):
import Control.Exception.Lifted ( mask, onException )


--------------------------------------------------------------------------------
-- * MVars
--------------------------------------------------------------------------------

-- | Generalized version of 'MVar.newEmptyMVar'.
newEmptyMVar ∷ MonadBase IO m ⇒ m (MVar α)
newEmptyMVar = liftBase MVar.newEmptyMVar
{-# INLINABLE newEmptyMVar #-}

-- | Generalized version of 'MVar.newMVar'.
newMVar ∷ MonadBase IO m ⇒ α → m (MVar α)
newMVar = liftBase ∘ MVar.newMVar
{-# INLINABLE newMVar #-}

-- | Generalized version of 'MVar.takeMVar'.
takeMVar ∷ MonadBase IO m ⇒ MVar α → m α
takeMVar = liftBase ∘ MVar.takeMVar
{-# INLINABLE takeMVar #-}

-- | Generalized version of 'MVar.putMVar'.
putMVar ∷ MonadBase IO m ⇒ MVar α → α → m ()
putMVar mv x = liftBase $ MVar.putMVar mv x
{-# INLINABLE putMVar #-}

-- | Generalized version of 'MVar.readMVar'.
readMVar ∷ MonadBase IO m ⇒ MVar α → m α
readMVar = liftBase ∘ MVar.readMVar
{-# INLINABLE readMVar #-}

-- | Generalized version of 'MVar.swapMVar'.
swapMVar ∷ MonadBase IO m ⇒ MVar α → α → m α
swapMVar mv x = liftBase $ MVar.swapMVar mv x
{-# INLINABLE swapMVar #-}

-- | Generalized version of 'MVar.tryTakeMVar'.
tryTakeMVar ∷ MonadBase IO m ⇒ MVar α → m (Maybe α)
tryTakeMVar = liftBase ∘ MVar.tryTakeMVar
{-# INLINABLE tryTakeMVar #-}

-- | Generalized version of 'MVar.tryPutMVar'.
tryPutMVar ∷ MonadBase IO m ⇒ MVar α → α → m Bool
tryPutMVar mv x = liftBase $ MVar.tryPutMVar mv x
{-# INLINABLE tryPutMVar #-}

-- | Generalized version of 'MVar.isEmptyMVar'.
isEmptyMVar ∷ MonadBase IO m ⇒ MVar α → m Bool
isEmptyMVar = liftBase ∘ MVar.isEmptyMVar
{-# INLINABLE isEmptyMVar #-}

-- | Generalized version of 'MVar.withMVar'.
withMVar ∷ MonadBaseControl IO m ⇒ MVar α → (α → m β) → m β
withMVar = liftBaseOp ∘ MVar.withMVar
{-# INLINABLE withMVar #-}

-- | Generalized version of 'MVar.modifyMVar_'.
modifyMVar_ ∷ (MonadBaseControl IO m, MonadBase IO m) ⇒ MVar α → (α → m α) → m ()
modifyMVar_ mv f = mask $ \restore → do
                     x  ← takeMVar mv
                     x' ← restore (f x) `onException` putMVar mv x
                     putMVar mv x'
{-# INLINABLE modifyMVar_ #-}

-- | Generalized version of 'MVar.modifyMVar'.
modifyMVar ∷ (MonadBaseControl IO m, MonadBase IO m) ⇒ MVar α → (α → m (α, β)) → m β
modifyMVar mv f = mask $ \restore → do
                    x       ← takeMVar mv
                    (x', y) ← restore (f x) `onException` putMVar mv x
                    putMVar mv x'
                    return y
{-# INLINABLE modifyMVar #-}

-- | Generalized version of 'MVar.addMVarFinalizer'.
--
-- Note any monadic side effects in @m@ of the \"finalizer\" computation are
-- discarded.
addMVarFinalizer ∷ MonadBaseControl IO m ⇒ MVar α → m () → m ()
addMVarFinalizer = liftBaseDiscard ∘ MVar.addMVarFinalizer
{-# INLINABLE addMVarFinalizer #-}
