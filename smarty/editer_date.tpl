<form method="post" action="?t=editer_date&date={$date->date_sortie|date_format:"%s"}&id_sortie={$date->id_sortie}">
	<!-- Sortie : <a href="?t=editer&sortie={$date->id_sortie}">{$sortie->nom}</a> <a href="?t=editer_suiv&id_sortie={$date->id_sortie}">(dates)</a><br/> -->
	Date : {$date->date_sortie|date_format:"%d-%m-%Y"}<br/>
	Heure du rendez-vous :
	{if $edit}
		<input type="text" name="date_sortie_h" size="2" value="{$date->date_sortie|date_format:"%H"}"/>:
		<input type="text" name="date_sortie_m" size="2" value="{$date->date_sortie|date_format:"%M"}"/><br/>
	{else}
		{$date->date_sortie|date_format:"%H:%M"}<br/>
	{/if}

	État : 
	{if !$admin}
		<b>{$date->etat_lib}</b>
	{else}
		<select name="etat">
			<option value="1" {if $date->etat eq 1}selected=true{/if}>proposée</option>
			<option value="2" {if $date->etat eq 2}selected=true{/if}>pas retenue</option>
			<option value="3" {if $date->etat eq 3}selected=true{/if}>valide</option>
			<option value="4" {if $date->etat eq 4}selected=true{/if}>annulée</option>
		</select>
	{/if}
	<br/>
	<label for="inscription_prealable">Inscription préalable</label>
	{if $edit}
		<input id="inscription_prealable" type="checkbox" name="inscription_prealable" {if $date->inscription_prealable eq true}checked=true{/if} value="1"/><br/>
	{else}
		<b>{if $date->inscription_prealable}oui{else}non{/if}</b><br/>
	{/if}
	Date limite d'inscription : 
	{if $edit}
		<input type="text" size="10" name="inscription_date_limite" id="inscription_date_limite" value="{$date->inscription_date_limite|date_format:"%d/%m/%Y"}"/><br/>
		<script>J('#inscription_date_limite').datepicker();</script>
	{else}
		<b>{$date->inscription_date_limite|date_format:"%d/%m/%Y"}</b><br/>
	{/if}
	Nombre de participants max :
	{if $edit}
		<input type="text" size="3" name="inscription_participants_max" value="{$date->inscription_participants_max}"/><br/>
	{else}
		<b>{$date->inscription_participants_max}</b><br/>
	{/if}
	{if $edit}<input type="submit" value="Enregistrer"/>{/if}
</form>
